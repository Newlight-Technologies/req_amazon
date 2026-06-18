defmodule ReqAmazon.SpApi.Token.CountingProvider do
  @moduledoc false
  @behaviour ReqAmazon.SpApi.Token.Provider

  @impl true
  def fetch(_grant, _credentials, _request_options, _owner) do
    counter = Application.fetch_env!(:req_amazon, :test_token_counter)
    :counters.add(counter, 1, 1)
    # Hold the refresh open so concurrent callers pile up behind a single flight.
    Process.sleep(50)
    {:ok, "token-#{:counters.get(counter, 1)}", DateTime.add(DateTime.utc_now(), 3600, :second)}
  end
end

defmodule ReqAmazon.SpApi.Token.CacheTest do
  use ExUnit.Case, async: false

  alias ReqAmazon.SpApi.Token.{Cache, CountingProvider}

  setup do
    counter = :counters.new(1, [:atomics])
    Application.put_env(:req_amazon, :test_token_counter, counter)
    Application.put_env(:req_amazon, :token_provider, CountingProvider)
    Cache.reset()

    on_exit(fn ->
      Application.delete_env(:req_amazon, :token_provider)
      Application.delete_env(:req_amazon, :test_token_counter)
      Cache.reset()
    end)

    {:ok, counter: counter, credentials: %{client_id: "client-1", client_secret: "secret-1"}}
  end

  test "coalesces concurrent refreshes for the same key into one provider call", %{
    counter: counter,
    credentials: credentials
  } do
    grant = {:refresh_token, "refresh-1"}

    results =
      1..25
      |> Task.async_stream(fn _ -> Cache.fetch(grant, credentials) end, max_concurrency: 25)
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.all?(results, &(&1 == {:ok, "token-1"}))
    assert :counters.get(counter, 1) == 1
  end

  test "serves cached tokens without re-calling the provider", %{
    counter: counter,
    credentials: credentials
  } do
    grant = {:refresh_token, "refresh-1"}

    assert {:ok, "token-1"} = Cache.fetch(grant, credentials)
    assert {:ok, "token-1"} = Cache.fetch(grant, credentials)
    assert :counters.get(counter, 1) == 1
  end

  test "refreshes independently per grant key", %{counter: counter, credentials: credentials} do
    assert {:ok, _} = Cache.fetch({:refresh_token, "refresh-1"}, credentials)

    assert {:ok, _} =
             Cache.fetch({:client_credentials, "sellingpartnerapi::notifications"}, credentials)

    assert :counters.get(counter, 1) == 2
  end

  test "distinct refresh tokens for the same client never share a token", %{
    counter: counter,
    credentials: credentials
  } do
    assert {:ok, token_a} = Cache.fetch({:refresh_token, "refresh-a"}, credentials)
    assert {:ok, token_b} = Cache.fetch({:refresh_token, "refresh-b"}, credentials)

    assert token_a != token_b
    assert :counters.get(counter, 1) == 2
  end

  test "key/2 is collision-resistant and stable for refresh tokens", %{credentials: credentials} do
    assert Cache.key({:refresh_token, "refresh-a"}, credentials) ==
             Cache.key({:refresh_token, "refresh-a"}, credentials)

    refute Cache.key({:refresh_token, "refresh-a"}, credentials) ==
             Cache.key({:refresh_token, "refresh-b"}, credentials)
  end
end

defmodule ReqAmazon.SpApi.TokenGrantlessTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Notifications, Response}

  test "grantless clients exchange client_credentials and reuse the token", %{
    credentials: credentials
  } do
    grantless_credentials = Map.delete(credentials, :refresh_token)

    Req.Test.stub(stub_name(), fn conn ->
      case {conn.host, conn.request_path} do
        {"api.amazon.com", "/auth/o2/token"} ->
          {:ok, body, _conn} = Plug.Conn.read_body(conn)
          form = URI.decode_query(body)
          assert form["grant_type"] == "client_credentials"
          assert form["scope"] == "sellingpartnerapi::notifications"
          refute Map.has_key?(form, "refresh_token")
          Req.Test.json(conn, %{"access_token" => "grantless-token", "expires_in" => 3600})

        {"sellingpartnerapi-na.amazon.com", "/notifications/v1/destinations"} ->
          assert Plug.Conn.get_req_header(conn, "x-amz-access-token") == ["grantless-token"]
          Req.Test.json(conn, %{"payload" => [%{"destinationId" => "dest-1"}]})
      end
    end)

    req =
      Client.new(
        credentials: grantless_credentials,
        grantless_scope: "sellingpartnerapi::notifications",
        plug: {Req.Test, stub_name()}
      )

    assert {:ok, %Response{body: [%{"destinationId" => "dest-1"}]}} =
             Notifications.get_destinations(req)
  end

  test "grantless clients do not require a refresh token", %{credentials: credentials} do
    grantless_credentials = Map.delete(credentials, :refresh_token)

    req =
      Client.new(
        credentials: grantless_credentials,
        grantless_scope: "sellingpartnerapi::notifications"
      )

    assert %Req.Request{} = req
  end
end
