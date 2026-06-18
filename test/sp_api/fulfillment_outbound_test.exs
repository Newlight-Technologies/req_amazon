defmodule ReqAmazon.SpApi.FulfillmentOutboundTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, FulfillmentOutbound}

  test "list_all_fulfillment_orders maps query params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/fba/outbound/2020-07-01/fulfillmentOrders"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["queryStartDate"] == "2026-03-01T00:00:00Z"
      assert params["nextToken"] == "next-1"
      Req.Test.json(conn, %{"payload" => %{"FulfillmentOrders" => [], "NextToken" => nil}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"FulfillmentOrders" => [], "NextToken" => nil}}} =
             FulfillmentOutbound.list_all_fulfillment_orders(req,
               query_start_date: "2026-03-01T00:00:00Z",
               next_token: "next-1"
             )
  end

  test "get_package_tracking_details sends packageNumber query param", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/fba/outbound/2020-07-01/tracking"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["packageNumber"] == "42"
      Req.Test.json(conn, %{"payload" => %{"trackingNumber" => "1Z999"}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"trackingNumber" => "1Z999"}}} =
             FulfillmentOutbound.get_package_tracking_details(req, "42")
  end

  test "cancel_fulfillment_order uses PUT on the cancel endpoint", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/fba/outbound/2020-07-01/fulfillmentOrders/order-123/cancel", "PUT"} =
        {conn.host, conn.request_path, conn.method}

      Req.Test.json(conn, %{"payload" => %{"status" => "Cancelled"}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"status" => "Cancelled"}}} =
             FulfillmentOutbound.cancel_fulfillment_order(req, "order-123")
  end
end
