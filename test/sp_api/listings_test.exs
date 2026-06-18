defmodule ReqAmazon.SpApi.ListingsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, Error, Listings}

  test "get_listings_item sends seller_id, sku, and marketplace params", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/items/SELLER%201/SKU%2F001"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["includedData"] == "summaries,issues"
      assert params["issueLocale"] == "en_US"
      Req.Test.json(conn, %{"sku" => "SKU-001", "summaries" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"sku" => "SKU-001"}}} =
             Listings.get_listings_item(req, "SELLER 1", "SKU/001",
               marketplace_ids: ["ATVPDKIKX0DER"],
               included_data: ["summaries", "issues"],
               issue_locale: "en_US"
             )
  end

  test "put_listings_item supports validation preview params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/items/SELLER1/SKU-001", "PUT"} =
        {conn.host, conn.request_path, conn.method}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["includedData"] == "issues,identifiers"
      assert params["mode"] == "VALIDATION_PREVIEW"
      assert params["issueLocale"] == "en_US"

      assert json_body(conn) == %{
               "productType" => "PRODUCT",
               "requirements" => "LISTING",
               "attributes" => %{}
             }

      Req.Test.json(conn, %{"sku" => "SKU-001", "status" => "ACCEPTED"})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"sku" => "SKU-001", "status" => "ACCEPTED"}}} =
             Listings.put_listings_item(
               req,
               "SELLER1",
               "SKU-001",
               [
                 marketplace_ids: ["ATVPDKIKX0DER"],
                 included_data: ["issues", "identifiers"],
                 mode: "VALIDATION_PREVIEW",
                 issue_locale: "en_US"
               ],
               %{"productType" => "PRODUCT", "requirements" => "LISTING", "attributes" => %{}}
             )
  end

  test "search_listings_items maps optional filters and pagination", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/items/SELLER1"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["includedData"] == "summaries,issues"
      assert params["identifiers"] == "EAN-1,EAN-2"
      assert params["identifiersType"] == "EAN"
      assert params["variationParentSku"] == "PARENT-1"
      assert params["packageHierarchySku"] == "CASE-1"
      assert params["withIssueSeverity"] == "ERROR,WARNING"
      assert params["withStatus"] == "BUYABLE"
      assert params["withoutStatus"] == "DISCOVERABLE"
      assert params["sortBy"] == "sku"
      assert params["sortOrder"] == "ASC"
      assert params["pageSize"] == "20"
      assert params["pageToken"] == "next-page"
      Req.Test.json(conn, %{"items" => [%{"sku" => "SKU-001"}], "pagination" => %{}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"items" => [%{"sku" => "SKU-001"}], "pagination" => %{}}}} =
             Listings.search_listings_items(req, "SELLER1",
               marketplace_ids: ["ATVPDKIKX0DER"],
               included_data: ["summaries", "issues"],
               identifiers: ["EAN-1", "EAN-2"],
               identifiers_type: "EAN",
               variation_parent_sku: "PARENT-1",
               package_hierarchy_sku: "CASE-1",
               with_issue_severity: ["ERROR", "WARNING"],
               with_status: ["BUYABLE"],
               without_status: ["DISCOVERABLE"],
               sort_by: "sku",
               sort_order: "ASC",
               page_size: 20,
               page_token: "next-page"
             )
  end

  test "listings errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/items/SELLER1/SKU-001"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID", "message" => "Bad listing"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID"}]}} =
             Listings.get_listings_item(req, "SELLER1", "SKU-001",
               marketplace_ids: ["ATVPDKIKX0DER"]
             )
  end
end
