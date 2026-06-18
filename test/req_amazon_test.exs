defmodule ReqAmazonTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, Error, Orders}

  test "client injects sandbox host, user agent, and caches the LWA token", %{
    credentials: credentials
  } do
    test_pid = self()

    Req.Test.stub(stub_name(), fn conn ->
      case {conn.host, conn.request_path} do
        {"api.amazon.com", "/auth/o2/token"} ->
          send(test_pid, {:token_request, query_params(conn)})
          Req.Test.json(conn, %{"access_token" => "lwa-token", "expires_in" => 3600})

        {"sandbox.sellingpartnerapi-na.amazon.com", path} ->
          send(
            test_pid,
            {:api_request, path, Plug.Conn.get_req_header(conn, "user-agent"),
             List.first(Plug.Conn.get_req_header(conn, "authorization")),
             List.first(Plug.Conn.get_req_header(conn, "x-amz-date"))}
          )

          assert_header(conn, "x-amz-access-token", "lwa-token")
          Req.Test.json(conn, %{"payload" => %{"AmazonOrderId" => "123-1234567-1234567"}})
      end
    end)

    req = Client.new(credentials: credentials, sandbox: true, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"AmazonOrderId" => "123-1234567-1234567"}}} =
             Orders.get_order(req, "123-1234567-1234567")

    assert {:ok, %Response{body: %{"AmazonOrderId" => "123-1234567-1234567"}}} =
             Orders.get_order(req, "123-1234567-1234567")

    assert_received {:token_request, %{}}
    refute_received {:token_request, _params}

    assert_received {:api_request, "/orders/v0/orders/123-1234567-1234567", [user_agent],
                     authorization, x_amz_date}

    assert String.starts_with?(user_agent, "req_amazon/")
    assert String.starts_with?(authorization, "AWS4-HMAC-SHA256 Credential=")
    assert authorization =~ "/us-east-1/execute-api/aws4_request"
    assert x_amz_date =~ ~r/^\d{8}T\d{6}Z$/
  end

  test "caller-supplied access token skips token exchange and honors endpoint overrides" do
    Req.Test.stub(stub_name(), fn conn ->
      case {conn.host, conn.request_path} do
        {"api.amazon.com", "/auth/o2/token"} ->
          flunk("unexpected LWA token request")

        {"sellingpartnerapi-eu.amazon.com", "/orders/v0/orders/123-1234567-1234567"} ->
          assert_header(conn, "x-amz-access-token", "caller-token")

          authorization = List.first(Plug.Conn.get_req_header(conn, "authorization"))
          assert authorization =~ "/eu-west-1/execute-api/aws4_request"

          Req.Test.json(conn, %{"payload" => %{"AmazonOrderId" => "123-1234567-1234567"}})
      end
    end)

    req =
      Client.new(
        access_token: "caller-token",
        base_url: "https://sellingpartnerapi-eu.amazon.com",
        credentials: %{
          aws_access_key_id: "AKIA-EU-1",
          aws_secret_access_key: "secret-access-eu-1",
          aws_region: "eu-west-1"
        },
        plug: {Req.Test, stub_name()}
      )

    assert {:ok, %Response{body: %{"AmazonOrderId" => "123-1234567-1234567"}}} =
             Orders.get_order(req, "123-1234567-1234567")
  end

  test "non-2xx responses become ReqAmazon.SpApi.Error", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", _path} = {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [
          %{
            "code" => "InvalidInput",
            "message" => "Bad request",
            "details" => "Nope"
          }
        ]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error,
            %Error{
              status: 400,
              errors: [%{"code" => "InvalidInput"} | _]
            }} = Orders.get_order(req, "123-1234567-1234567")
  end

  test "credentials accepts string-keyed maps" do
    assert %{
             client_id: "client-1",
             client_secret: "secret-1",
             refresh_token: "refresh-1",
             aws_access_key_id: "AKIA1",
             aws_secret_access_key: "secret-access-1",
             aws_region: "us-east-1"
           } =
             ReqAmazon.SpApi.credentials(%{
               "client_id" => "client-1",
               "client_secret" => "secret-1",
               "refresh_token" => "refresh-1",
               "aws_access_key_id" => "AKIA1",
               "aws_secret_access_key" => "secret-access-1"
             })
  end

  test "malformed token responses become ReqAmazon.SpApi.Error", %{credentials: credentials} do
    Req.Test.stub(stub_name(), fn conn ->
      case {conn.host, conn.request_path} do
        {"api.amazon.com", "/auth/o2/token"} ->
          Req.Test.json(conn, %{"access_token" => "lwa-token", "expires_in" => "soon"})

        {"sellingpartnerapi-na.amazon.com", _path} ->
          flunk("unexpected SP-API request after malformed token response")
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error,
            %Error{
              status: 200,
              errors: [%{"code" => "InvalidTokenResponse"} | _]
            }} = Orders.get_order(req, "123-1234567-1234567")
  end

  test "path_segment uses path encoding" do
    assert ReqAmazon.path_segment("a b/c") == "a%20b%2Fc"
  end

  test "put_csv_param omits empty optional lists" do
    assert ReqAmazon.put_csv_param(%{}, "marketplaceIds", nil) == %{}
    assert ReqAmazon.put_csv_param(%{}, "marketplaceIds", []) == %{}

    assert ReqAmazon.put_csv_param(%{}, "marketplaceIds", ["ATVPDKIKX0DER", "A2EUQ1WTGCTBG2"]) ==
             %{"marketplaceIds" => "ATVPDKIKX0DER,A2EUQ1WTGCTBG2"}
  end
end
