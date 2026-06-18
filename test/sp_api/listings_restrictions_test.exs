defmodule ReqAmazon.SpApi.ListingsRestrictionsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Listings, ListingsRestrictions}

  test "get_listings_restrictions maps documented params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/restrictions"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["asin"] == "B000123"
      assert params["sellerId"] == "SELLER1"
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["conditionType"] == "new_new"
      assert params["reasonLocale"] == "en_US"
      assert params["productType"] == "LUGGAGE"

      Req.Test.json(conn, %{"restrictions" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"restrictions" => []}} =
             ListingsRestrictions.get_listings_restrictions(req,
               asin: "B000123",
               seller_id: "SELLER1",
               marketplace_ids: ["ATVPDKIKX0DER"],
               condition_type: "new_new",
               reason_locale: "en_US",
               product_type: "LUGGAGE"
             )
  end

  test "legacy Listings module delegates to ListingsRestrictions", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/listings/2021-08-01/restrictions"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["asin"] == "B000123"
      assert params["sellerId"] == "SELLER1"
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"

      Req.Test.json(conn, %{"restrictions" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"restrictions" => []}} =
             Listings.get_listings_restrictions(req,
               asin: "B000123",
               seller_id: "SELLER1",
               marketplace_ids: ["ATVPDKIKX0DER"]
             )
  end
end
