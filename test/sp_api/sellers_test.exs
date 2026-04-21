defmodule ReqAmazon.SpApi.SellersTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, Sellers}

  test "get_marketplace_participations and get_account hit the expected seller endpoints", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/sellers/v1/marketplaceParticipations", "GET"} ->
          Req.Test.json(conn, %{"payload" => [%{"marketplace" => %{"id" => "ATVPDKIKX0DER"}}]})

        {"sellingpartnerapi-na.amazon.com", "/sellers/v1/account", "GET"} ->
          Req.Test.json(conn, %{"businessType" => "PRIVATE_LABEL"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, [%{"marketplace" => %{"id" => "ATVPDKIKX0DER"}}]} =
             Sellers.get_marketplace_participations(req)

    assert {:ok, %{"businessType" => "PRIVATE_LABEL"}} = Sellers.get_account(req)
  end

  test "sellers errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/sellers/v1/account"} = {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad sellers request"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             Sellers.get_account(req)
  end
end
