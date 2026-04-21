defmodule ReqAmazon.SpApi.ProductTypeDefinitionsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, ProductTypeDefinitions}

  test "search_definitions_product_types maps documented optional params", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/definitions/2020-09-01/productTypes"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["keywords"] == "shirt"
      assert params["locale"] == "en_US"
      assert params["searchLocale"] == "en_US"
      Req.Test.json(conn, %{"productTypes" => [%{"name" => "SHIRT"}]})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"productTypes" => [%{"name" => "SHIRT"}]}} =
             ProductTypeDefinitions.search_definitions_product_types(req,
               marketplace_ids: ["ATVPDKIKX0DER"],
               keywords: "shirt",
               locale: "en_US",
               search_locale: "en_US"
             )
  end

  test "get_definitions_product_type maps request options and escapes product type", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/definitions/2020-09-01/productTypes/HOME%20%2F%20DECOR"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["sellerId"] == "SELLER1"
      assert params["productTypeVersion"] == "LATEST"
      assert params["requirements"] == "LISTING"
      assert params["requirementsEnforced"] == "ENFORCED"
      assert params["locale"] == "en_US"
      Req.Test.json(conn, %{"name" => "HOME / DECOR"})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"name" => "HOME / DECOR"}} =
             ProductTypeDefinitions.get_definitions_product_type(req, "HOME / DECOR",
               marketplace_ids: ["ATVPDKIKX0DER"],
               seller_id: "SELLER1",
               product_type_version: "LATEST",
               requirements: "LISTING",
               requirements_enforced: "ENFORCED",
               locale: "en_US"
             )
  end

  test "product type definition errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/definitions/2020-09-01/productTypes/SHIRT"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad product type"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             ProductTypeDefinitions.get_definitions_product_type(req, "SHIRT",
               marketplace_ids: ["ATVPDKIKX0DER"]
             )
  end
end
