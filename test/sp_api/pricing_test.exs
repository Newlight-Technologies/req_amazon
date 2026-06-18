defmodule ReqAmazon.SpApi.PricingTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, Error, Pricing}

  test "get_pricing maps legacy v0 query params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/products/pricing/v0/price"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["MarketplaceId"] == "ATVPDKIKX0DER"
      assert params["ItemType"] == "Asin"
      assert params["Asins"] == "B000123,B000456"
      assert params["ItemCondition"] == "New"
      assert params["OfferType"] == "B2C"

      Req.Test.json(conn, %{"payload" => %{"Products" => [%{"ASIN" => "B000123"}]}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"Products" => [%{"ASIN" => "B000123"}]}}} =
             Pricing.get_pricing(req,
               marketplace_id: "ATVPDKIKX0DER",
               item_type: "Asin",
               asins: ["B000123", "B000456"],
               item_condition: "New",
               offer_type: "B2C"
             )
  end

  test "get_listing_offers escapes the sku path segment", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/products/pricing/v0/listings/SKU%2F123/offers"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["MarketplaceId"] == "ATVPDKIKX0DER"
      assert params["ItemCondition"] == "New"
      assert params["CustomerType"] == "Consumer"

      Req.Test.json(conn, %{"payload" => %{"Summary" => %{"BuyBoxPrices" => []}}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"Summary" => %{"BuyBoxPrices" => []}}}} =
             Pricing.get_listing_offers(req, "SKU/123",
               marketplace_id: "ATVPDKIKX0DER",
               item_condition: "New",
               customer_type: "Consumer"
             )
  end

  test "legacy pricing errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/products/pricing/v0/items/B000123/offers"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad pricing request"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             Pricing.get_item_offers(req, "B000123",
               marketplace_id: "ATVPDKIKX0DER",
               item_condition: "New"
             )
  end
end
