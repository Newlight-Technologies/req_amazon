defmodule ReqAmazon.SpApi.OrdersTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Orders}

  test "list_orders maps query params and unwraps payload", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/v0/orders"} = {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["MarketplaceIds"] == "ATVPDKIKX0DER"
      assert params["CreatedAfter"] == "2026-03-01T00:00:00Z"
      assert params["OrderStatuses"] == "Unshipped,PartiallyShipped"
      assert params["FulfillmentChannels"] == "AFN,MFN"

      Req.Test.json(conn, %{
        "payload" => %{"Orders" => [%{"AmazonOrderId" => "123"}], "NextToken" => nil}
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"Orders" => [%{"AmazonOrderId" => "123"}], "NextToken" => nil}} =
             Orders.list_orders(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               created_after: "2026-03-01T00:00:00Z",
               order_statuses: ["Unshipped", "PartiallyShipped"],
               fulfillment_channels: ["AFN", "MFN"]
             )
  end

  test "confirm_shipment posts the request body", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/v0/orders/123/shipmentConfirmation"} =
        {conn.host, conn.request_path}

      assert json_body(conn) == %{"packageDetail" => %{"packageReferenceId" => "pkg-1"}}
      Req.Test.json(conn, %{"payload" => %{"confirmed" => true}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"confirmed" => true}} =
             Orders.confirm_shipment(req, "123", %{
               "packageDetail" => %{"packageReferenceId" => "pkg-1"}
             })
  end

  test "get_order_items sends the next token when present", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/v0/orders/123/orderItems"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["NextToken"] == "next-1"
      Req.Test.json(conn, %{"payload" => %{"OrderItems" => [%{"OrderItemId" => "1"}]}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"OrderItems" => [%{"OrderItemId" => "1"}]}} =
             Orders.get_order_items(req, "123", next_token: "next-1")
  end
end
