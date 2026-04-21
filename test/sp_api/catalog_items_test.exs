defmodule ReqAmazon.SpApi.CatalogItemsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{CatalogItems, Client, Error}

  test "search_catalog_items maps asin_list to identifiers and included data", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/catalog/2022-04-01/items"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["identifiers"] == "B001234567,B008765432"
      assert params["identifiersType"] == "ASIN"
      assert params["includedData"] == "summaries,images"
      Req.Test.json(conn, %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               asin_list: ["B001234567", "B008765432"],
               included_data: ["summaries", "images"]
             )
  end

  test "search_catalog_items rejects both keywords and asin_list", %{credentials: credentials} do
    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{message: message}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               keywords: ["poncho"],
               asin_list: ["B001234567"]
             )

    assert message =~ "either :keywords or :asin_list"
  end

  test "get_catalog_item sends marketplace and included data params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/catalog/2022-04-01/items/B001234567"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["includedData"] == "summaries,images"
      Req.Test.json(conn, %{"asin" => "B001234567"})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"asin" => "B001234567"}} =
             CatalogItems.get_catalog_item(req, "B001234567",
               marketplace_ids: ["ATVPDKIKX0DER"],
               included_data: ["summaries", "images"]
             )
  end
end
