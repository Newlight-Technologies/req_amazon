defmodule ReqAmazon.SpApi.FbaInventoryTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, FbaInventory}

  test "get_inventory_summaries sets marketplace granularity fields", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/fba/inventory/v1/summaries"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["granularityType"] == "Marketplace"
      assert params["granularityId"] == "ATVPDKIKX0DER"
      assert params["sellerSkus"] == "SKU-1,SKU-2"
      assert params["details"] == "true"
      Req.Test.json(conn, %{"inventorySummaries" => [], "pagination" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"inventorySummaries" => [], "pagination" => %{}}} =
             FbaInventory.get_inventory_summaries(req, "ATVPDKIKX0DER",
               skus: ["SKU-1", "SKU-2"],
               details: true
             )
  end

  test "get_inventory_summaries omits details when the caller does not specify it", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/fba/inventory/v1/summaries"} =
        {conn.host, conn.request_path}

      refute Map.has_key?(query_params(conn), "details")
      Req.Test.json(conn, %{"inventorySummaries" => [], "pagination" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"inventorySummaries" => [], "pagination" => %{}}} =
             FbaInventory.get_inventory_summaries(req, "ATVPDKIKX0DER")
  end
end
