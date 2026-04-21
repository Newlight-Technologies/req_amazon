defmodule ReqAmazon.SpApi.PricingV20220501Test do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, PricingV20220501}

  test "get_featured_offer_expected_price_batch posts the current pricing batch payload", %{
    credentials: credentials
  } do
    payload = %{"requests" => [%{"uri" => "/products/pricing/v0/listings/SKU-1/offers"}]}

    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/batches/products/pricing/2022-05-01/offer/featuredOfferExpectedPrice"} =
        {conn.host, conn.request_path}

      assert json_body(conn) == payload
      Req.Test.json(conn, %{"responses" => [%{"status" => 200}]})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"responses" => [%{"status" => 200}]}} =
             PricingV20220501.get_featured_offer_expected_price_batch(req, payload)
  end

  test "get_competitive_summary posts the current competitive summary payload", %{
    credentials: credentials
  } do
    payload = %{"requests" => [%{"asin" => "B000123", "marketplaceId" => "ATVPDKIKX0DER"}]}

    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/batches/products/pricing/2022-05-01/items/competitiveSummary"} =
        {conn.host, conn.request_path}

      assert json_body(conn) == payload
      Req.Test.json(conn, %{"responses" => [%{"status" => 200}]})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"responses" => [%{"status" => 200}]}} =
             PricingV20220501.get_competitive_summary(req, payload)
  end

  test "current pricing errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/batches/products/pricing/2022-05-01/items/competitiveSummary"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad pricing batch"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             PricingV20220501.get_competitive_summary(req, %{"requests" => []})
  end
end
