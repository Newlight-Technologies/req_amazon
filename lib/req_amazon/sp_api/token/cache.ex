defmodule ReqAmazon.SpApi.Token.Cache do
  @moduledoc false

  # Caches Login with Amazon access tokens with single-flight refresh.
  #
  # Design goals (this replaces the old blocking Auth GenServer):
  #
  #   * Cache hits never touch the GenServer — they read a public ETS table
  #     directly, so concurrent callers (e.g. an Oban fleet) don't serialize.
  #   * Concurrent misses for the same key coalesce into ONE provider call;
  #     everyone waiting on that key gets the same result.
  #   * The GenServer never blocks on the token HTTP round-trip — the provider
  #     runs in a Task, so unrelated keys refresh concurrently.

  use GenServer

  alias ReqAmazon.SpApi.Token.Provider

  @table __MODULE__
  # Refresh a little before expiry so in-flight requests don't race the boundary.
  @refresh_window_seconds 60
  @call_timeout 20_000

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @doc """
  Returns a valid access token for `grant`, minting and caching one if needed.
  """
  @spec fetch(Provider.grant(), ReqAmazon.SpApi.credentials(), keyword(), pid()) ::
          {:ok, String.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def fetch(grant, credentials, request_options \\ [], owner \\ self()) do
    key = key(grant, credentials)

    case lookup_valid(key) do
      {:ok, token} ->
        {:ok, token}

      :miss ->
        GenServer.call(
          __MODULE__,
          {:fetch, key, grant, credentials, request_options, owner},
          @call_timeout
        )
    end
  end

  @doc false
  @spec reset() :: :ok
  def reset do
    case Process.whereis(__MODULE__) do
      nil -> :ok
      _pid -> GenServer.call(__MODULE__, :reset)
    end
  end

  @doc false
  @spec key(Provider.grant(), map()) :: term()
  def key({:refresh_token, refresh_token}, %{client_id: client_id}) do
    # Avoid keeping the refresh token in the key; the hash is enough to scope it.
    {:refresh_token, client_id, :erlang.phash2(refresh_token)}
  end

  def key({:client_credentials, scope}, %{client_id: client_id}) do
    {:client_credentials, client_id, scope}
  end

  defp lookup_valid(key) do
    case :ets.lookup(@table, key) do
      [{^key, token, expires_at}] when is_binary(token) ->
        if DateTime.diff(expires_at, DateTime.utc_now(), :second) > @refresh_window_seconds do
          {:ok, token}
        else
          :miss
        end

      _ ->
        :miss
    end
  end

  @impl true
  def init(:ok) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    {:ok, %{inflight: %{}}}
  end

  @impl true
  def handle_call(:reset, _from, state) do
    :ets.delete_all_objects(@table)
    {:reply, :ok, %{state | inflight: %{}}}
  end

  def handle_call({:fetch, key, grant, credentials, request_options, owner}, from, state) do
    # Re-check under the GenServer: another caller may have just populated it.
    case lookup_valid(key) do
      {:ok, token} ->
        {:reply, {:ok, token}, state}

      :miss ->
        state =
          case Map.get(state.inflight, key) do
            nil ->
              start_refresh(key, grant, credentials, request_options, owner)
              put_in(state.inflight[key], [from])

            waiters ->
              put_in(state.inflight[key], [from | waiters])
          end

        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:token_result, key, result}, state) do
    {waiters, inflight} = Map.pop(state.inflight, key, [])

    reply =
      case result do
        {:ok, token, expires_at} ->
          :ets.insert(@table, {key, token, expires_at})
          {:ok, token}

        {:error, _error} = error ->
          error
      end

    Enum.each(waiters, &GenServer.reply(&1, reply))
    {:noreply, %{state | inflight: inflight}}
  end

  defp start_refresh(key, grant, credentials, request_options, owner) do
    parent = self()
    provider = provider()

    Task.start(fn ->
      result =
        try do
          provider.fetch(grant, credentials, request_options, owner)
        rescue
          exception -> {:error, ReqAmazon.SpApi.Error.wrap(exception)}
        catch
          kind, reason -> {:error, ReqAmazon.SpApi.Error.wrap({kind, reason})}
        end

      send(parent, {:token_result, key, result})
    end)
  end

  defp provider do
    Application.get_env(:req_amazon, :token_provider, ReqAmazon.SpApi.Token.Lwa)
  end
end
