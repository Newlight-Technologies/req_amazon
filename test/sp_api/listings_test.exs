defmodule ReqAmazon.SpApi.ListingsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Listings}

  test "get_listings_item sends seller_id, sku, and marketplace params", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/items/SELLER1/SKU-001"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["includedData"] == "summaries,issues"
      Req.Test.json(conn, %{"sku" => "SKU-001", "summaries" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"sku" => "SKU-001"}} =
             Listings.get_listings_item(req, "SELLER1", "SKU-001",
               marketplace_ids: ["ATVPDKIKX0DER"],
               included_data: ["summaries", "issues"]
             )
  end

  test "put_listings_item sends JSON body with marketplace params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/items/SELLER1/SKU-001", "PUT"} =
        {conn.host, conn.request_path, conn.method}

      assert json_body(conn) == %{"productType" => "PRODUCT", "attributes" => %{}}
      Req.Test.json(conn, %{"sku" => "SKU-001", "status" => "ACCEPTED"})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"sku" => "SKU-001", "status" => "ACCEPTED"}} =
             Listings.put_listings_item(
               req,
               "SELLER1",
               "SKU-001",
               [marketplace_ids: ["ATVPDKIKX0DER"]],
               %{"productType" => "PRODUCT", "attributes" => %{}}
             )
  end
end
