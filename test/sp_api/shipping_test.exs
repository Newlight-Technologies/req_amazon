defmodule ReqAmazon.SpApi.ShippingTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Shipping}

  test "additional input schema uses modeled path", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/shipping/v2/shipments/additionalInputs/schema", "GET"} =
        {conn.host, conn.request_path, conn.method}

      assert query_params(conn) == %{"requestToken" => "token-1", "rateId" => "rate-1"}

      Req.Test.json(conn, %{"schema" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"schema" => %{}}} =
             Shipping.get_additional_inputs(req, request_token: "token-1", rate_id: "rate-1")
  end

  test "unmanifested shipments uses PUT", %{credentials: credentials} do
    payload = %{"marketplaceId" => "ATVPDKIKX0DER"}

    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/shipping/v2/unmanifestedShipments", "PUT"} =
        {conn.host, conn.request_path, conn.method}

      assert json_body(conn) == payload

      Req.Test.json(conn, %{"shipments" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"shipments" => []}} = Shipping.get_unmanifested_shipments(req, payload)
  end
end
