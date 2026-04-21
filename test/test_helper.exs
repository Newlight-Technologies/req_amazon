ExUnit.start()

Application.ensure_all_started(:req_amazon)

defmodule ReqAmazon.TestHelpers do
  import ExUnit.Assertions

  @stub ReqAmazon.SpApi.Client

  def credentials(overrides \\ %{}) do
    unique = System.unique_integer([:positive])

    Map.merge(
      %{
        client_id: "client-#{unique}",
        client_secret: "secret-#{unique}",
        refresh_token: "refresh-#{unique}",
        aws_access_key_id: "AKIA#{unique}",
        aws_secret_access_key: "secret-access-#{unique}",
        aws_region: "us-east-1"
      },
      overrides
    )
  end

  def stub_name, do: @stub

  def stub_with_token(handler) when is_function(handler, 1) do
    Req.Test.stub(stub_name(), fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"api.amazon.com", "/auth/o2/token", "POST"} ->
          Req.Test.json(conn, %{"access_token" => "lwa-token", "expires_in" => 3600})

        _ ->
          handler.(conn)
      end
    end)
  end

  def query_params(conn) do
    conn
    |> Plug.Conn.fetch_query_params()
    |> Map.fetch!(:query_params)
  end

  def json_body(conn) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    case body do
      "" -> %{}
      _ -> Jason.decode!(body)
    end
  end

  def json_response(conn, status, body) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(body))
  end

  def assert_header(conn, name, expected) do
    assert Plug.Conn.get_req_header(conn, name) == [expected]
  end
end

defmodule ReqAmazon.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import ReqAmazon.TestHelpers
    end
  end

  setup _context do
    original_env = %{
      sp_api_credentials: Application.get_env(:req_amazon, :sp_api_credentials),
      sp_api_endpoint: Application.get_env(:req_amazon, :sp_api_endpoint),
      sp_api_marketplace_id: Application.get_env(:req_amazon, :sp_api_marketplace_id),
      sp_api_token_url: Application.get_env(:req_amazon, :sp_api_token_url),
      sp_api_user_agent: Application.get_env(:req_amazon, :sp_api_user_agent)
    }

    credentials = ReqAmazon.TestHelpers.credentials()

    Application.put_env(:req_amazon, :sp_api_credentials, credentials)

    Application.put_env(
      :req_amazon,
      :sp_api_endpoint,
      "https://sellingpartnerapi-na.amazon.com"
    )

    Application.put_env(:req_amazon, :sp_api_marketplace_id, "ATVPDKIKX0DER")
    Application.delete_env(:req_amazon, :sp_api_token_url)
    Application.delete_env(:req_amazon, :sp_api_user_agent)

    ReqAmazon.SpApi.Auth.reset()

    on_exit(fn ->
      Enum.each(original_env, fn
        {key, nil} -> Application.delete_env(:req_amazon, key)
        {key, value} -> Application.put_env(:req_amazon, key, value)
      end)

      ReqAmazon.SpApi.Auth.reset()
    end)

    {:ok, credentials: credentials}
  end
end
