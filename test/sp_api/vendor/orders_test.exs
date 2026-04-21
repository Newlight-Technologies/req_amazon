defmodule ReqAmazon.SpApi.Vendor.OrdersTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Vendor}

  test "get_purchase_orders maps query params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/vendor/orders/v1/purchaseOrders"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["createdAfter"] == "2026-03-01T00:00:00Z"
      assert params["purchaseOrderState"] == "New"

      Req.Test.json(conn, %{
        "payload" => %{"orders" => [%{"purchaseOrderNumber" => "PO-001"}]}
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"orders" => [%{"purchaseOrderNumber" => "PO-001"}]}} =
             Vendor.Orders.get_purchase_orders(req,
               created_after: "2026-03-01T00:00:00Z",
               purchase_order_state: "New"
             )
  end

  test "submit_acknowledgement posts the raw body", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/vendor/orders/v1/acknowledgements", "POST"} =
        {conn.host, conn.request_path, conn.method}

      assert json_body(conn) == %{"acknowledgements" => [%{"purchaseOrderNumber" => "PO-001"}]}
      Req.Test.json(conn, %{"payload" => %{"transactionId" => "tx-1"}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"transactionId" => "tx-1"}} =
             Vendor.Orders.submit_acknowledgement(req, %{
               "acknowledgements" => [%{"purchaseOrderNumber" => "PO-001"}]
             })
  end
end
