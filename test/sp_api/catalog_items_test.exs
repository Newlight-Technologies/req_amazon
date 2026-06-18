defmodule ReqAmazon.SpApi.CatalogItemsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, CatalogItems, Client, Error}

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

    assert {:ok, %Response{body: %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}}}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               asin_list: ["B001234567", "B008765432"],
               included_data: ["summaries", "images"]
             )
  end

  test "search_catalog_items maps identifier search with seller and locale options", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/catalog/2022-04-01/items"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["identifiers"] == "SKU-001"
      assert params["identifiersType"] == "SKU"
      assert params["sellerId"] == "SELLER1"
      assert params["locale"] == "en_US"
      assert params["pageSize"] == "20"
      assert params["pageToken"] == "next-token"
      Req.Test.json(conn, %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}}}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               identifiers: ["SKU-001"],
               identifiers_type: "SKU",
               seller_id: "SELLER1",
               locale: "en_US",
               page_size: 20,
               page_token: "next-token"
             )
  end

  test "search_catalog_items maps keyword filters", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/catalog/2022-04-01/items"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["keywords"] == "poncho,rain"
      assert params["brandNames"] == "Acme"
      assert params["classificationIds"] == "1234,5678"
      assert params["keywordsLocale"] == "en_US"
      Req.Test.json(conn, %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"items" => [%{"asin" => "B001234567"}], "pagination" => %{}}}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               keywords: ["poncho", "rain"],
               brand_names: ["Acme"],
               classification_ids: ["1234", "5678"],
               keywords_locale: "en_US"
             )
  end

  test "search_catalog_items rejects both keywords and identifier search modes", %{
    credentials: credentials
  } do
    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{message: message}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               keywords: ["poncho"],
               identifiers: ["B001234567"],
               identifiers_type: "ASIN"
             )

    assert message =~ "either :keywords or :identifiers/:asin_list"
  end

  test "search_catalog_items rejects SKU identifiers without seller_id", %{
    credentials: credentials
  } do
    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{message: message}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               identifiers: ["SKU-001"],
               identifiers_type: "SKU"
             )

    assert message =~ ":seller_id is required"
  end

  test "get_catalog_item sends marketplace, locale, and escaped path params", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/catalog/2022-04-01/items/B00123%2F4567"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["includedData"] == "summaries,images"
      assert params["locale"] == "en_US"
      Req.Test.json(conn, %{"asin" => "B001234567"})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"asin" => "B001234567"}}} =
             CatalogItems.get_catalog_item(req, "B00123/4567",
               marketplace_ids: ["ATVPDKIKX0DER"],
               included_data: ["summaries", "images"],
               locale: "en_US"
             )
  end

  test "catalog item errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/catalog/2022-04-01/items"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad query"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             CatalogItems.search_catalog_items(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               keywords: ["poncho"]
             )
  end
end
