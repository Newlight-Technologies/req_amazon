defmodule ReqAmazon.SpApi.OrdersV20260101Test do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, Error, OrdersV20260101}

  test "search_orders maps current query params and list_orders delegates to it", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/2026-01-01/orders"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["createdAfter"] == "2026-03-01T00:00:00Z"
      assert params["createdBefore"] == "2026-03-07T00:00:00Z"
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["fulfillmentStatuses"] == "UNSHIPPED,SHIPPED"
      assert params["fulfilledBy"] == "MERCHANT,AMAZON"
      assert params["maxResultsPerPage"] == "25"
      assert params["paginationToken"] == "next-page"
      assert params["includedData"] == "BUYER,RECIPIENT"

      Req.Test.json(conn, %{
        "orders" => [%{"orderId" => "123-1234567-1234567"}],
        "pagination" => %{}
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok,
            %Response{
              body: %{"orders" => [%{"orderId" => "123-1234567-1234567"}], "pagination" => %{}}
            }} =
             OrdersV20260101.list_orders(req,
               created_after: "2026-03-01T00:00:00Z",
               created_before: "2026-03-07T00:00:00Z",
               marketplace_ids: ["ATVPDKIKX0DER"],
               fulfillment_statuses: ["UNSHIPPED", "SHIPPED"],
               fulfilled_by: ["MERCHANT", "AMAZON"],
               max_results_per_page: 25,
               pagination_token: "next-page",
               included_data: ["BUYER", "RECIPIENT"]
             )
  end

  test "get_order compatibility helpers add included data and escape order ids", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/2026-01-01/orders/123%2F456"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["includedData"] == "FULFILLMENT,BUYER"
      Req.Test.json(conn, %{"orderId" => "123/456", "orderItems" => [%{"orderItemId" => "1"}]})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok,
            %Response{body: %{"orderId" => "123/456", "orderItems" => [%{"orderItemId" => "1"}]}}} =
             OrdersV20260101.get_order_items_buyer_info(req, "123/456",
               included_data: ["FULFILLMENT"]
             )
  end

  test "get_order_address requests recipient data", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/2026-01-01/orders/123-1234567-1234567"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["includedData"] == "RECIPIENT"
      Req.Test.json(conn, %{"orderId" => "123-1234567-1234567", "recipient" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"orderId" => "123-1234567-1234567", "recipient" => %{}}}} =
             OrdersV20260101.get_order_address(req, "123-1234567-1234567")
  end

  test "orders v2026 errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/2026-01-01/orders/123-1234567-1234567"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad order"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             OrdersV20260101.get_order(req, "123-1234567-1234567")
  end
end
