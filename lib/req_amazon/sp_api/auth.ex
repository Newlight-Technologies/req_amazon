defmodule ReqAmazon.SpApi.Auth do
  @moduledoc false

  use GenServer

  alias ReqAmazon.SpApi.Error

  @refresh_window_seconds 60

  @type token_entry :: %{
          access_token: String.t(),
          expires_at: DateTime.t()
        }

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, Keyword.put_new(opts, :name, __MODULE__))
  end

  @spec fetch_access_token(ReqAmazon.SpApi.credentials(), keyword(), pid()) ::
          {:ok, String.t()} | {:error, Error.t()}
  def fetch_access_token(credentials, request_options \\ [], owner \\ self()) do
    GenServer.call(
      __MODULE__,
      {:fetch_access_token, ReqAmazon.SpApi.credentials(credentials), request_options, owner},
      15_000
    )
  end

  @doc false
  @spec reset() :: :ok
  def reset do
    case Process.whereis(__MODULE__) do
      nil -> :ok
      _pid -> GenServer.call(__MODULE__, :reset)
    end
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{}}
  end

  def handle_call({:fetch_access_token, credentials, request_options, owner}, _from, state) do
    client_id = credentials.client_id

    case Map.get(state, client_id) do
      %{access_token: access_token, expires_at: expires_at}
      when is_binary(access_token) ->
        if DateTime.diff(expires_at, DateTime.utc_now(), :second) > @refresh_window_seconds do
          {:reply, {:ok, access_token}, state}
        else
          refresh_access_token(credentials, request_options, owner, state)
        end

      _ ->
        refresh_access_token(credentials, request_options, owner, state)
    end
  end

  defp refresh_access_token(credentials, request_options, owner, state) do
    case request_new_token(credentials, request_options, owner) do
      {:ok, access_token, expires_at} ->
        new_state =
          Map.put(state, credentials.client_id, %{
            access_token: access_token,
            expires_at: expires_at
          })

        {:reply, {:ok, access_token}, new_state}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  defp request_new_token(credentials, request_options, owner) do
    maybe_allow_req_test(request_options, owner)

    form = [
      grant_type: "refresh_token",
      client_id: credentials.client_id,
      client_secret: credentials.client_secret,
      refresh_token: credentials.refresh_token
    ]

    options =
      request_options
      |> Keyword.merge(form: form)
      |> Keyword.put_new(:retry, :transient)

    case Req.post(ReqAmazon.SpApi.token_url(), options) do
      {:ok,
       %Req.Response{
         status: status,
         body: %{"access_token" => access_token, "expires_in" => expires_in}
       }}
      when status in 200..299 ->
        case normalize_expires_in(expires_in) do
          {:ok, seconds} ->
            {:ok, access_token, DateTime.add(DateTime.utc_now(), seconds, :second)}

          :error ->
            {:error,
             Error.from_response(status, %{
               "errors" => [
                 %{
                   "code" => "InvalidTokenResponse",
                   "message" => "Amazon LWA token response included invalid expires_in"
                 }
               ]
             })}
        end

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, Error.from_response(status, body)}

      {:error, error} ->
        {:error, Error.wrap(error)}
    end
  end

  defp maybe_allow_req_test(request_options, owner) do
    case Keyword.get(request_options, :plug) do
      {Req.Test, name} when is_pid(owner) ->
        _ = Req.Test.allow(name, owner, self())
        :ok

      _ ->
        :ok
    end
  end

  defp normalize_expires_in(expires_in) when is_integer(expires_in), do: {:ok, expires_in}

  defp normalize_expires_in(expires_in) when is_binary(expires_in) do
    case Integer.parse(expires_in) do
      {seconds, ""} -> {:ok, seconds}
      _invalid -> :error
    end
  end

  defp normalize_expires_in(_expires_in), do: :error
end
