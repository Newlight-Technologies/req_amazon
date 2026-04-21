defmodule ReqAmazon.SpApi.PricingV20220501 do
  @moduledoc """
  Product Pricing v2022-05-01 batch operations.

  This current Pricing wrapper lives alongside the legacy
  `ReqAmazon.SpApi.Pricing` v0 module.
  """

  @base_path "/batches/products/pricing/2022-05-01"

  @spec get_featured_offer_expected_price_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_featured_offer_expected_price_batch(%Req.Request{} = req, payload)
      when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/offer/featuredOfferExpectedPrice",
      json: payload
    )
  end

  @spec get_competitive_summary(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_competitive_summary(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/items/competitiveSummary",
      json: payload
    )
  end
end
