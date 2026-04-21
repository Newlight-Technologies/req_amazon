defmodule ReqAmazon.SpApi.Pricing do
  @moduledoc """
  Product Pricing v0 operations.

  This legacy module wraps the Product Pricing v0 surface.

  The current Product Pricing `v2022-05-01` batch endpoints live in
  `ReqAmazon.SpApi.PricingV20220501`.

  For backwards compatibility, the current batch calls remain available here as
  deprecated delegates.
  """

  import ReqAmazon
  alias ReqAmazon.SpApi.PricingV20220501

  @base_path "/products/pricing/v0"

  @spec get_pricing(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_pricing(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    item_type = Keyword.fetch!(opts, :item_type)

    params =
      %{}
      |> put_param("MarketplaceId", marketplace_id)
      |> put_param("ItemType", item_type)
      |> put_csv_param("Asins", Keyword.get(opts, :asins))
      |> put_csv_param("Skus", Keyword.get(opts, :skus))
      |> put_param("ItemCondition", Keyword.get(opts, :item_condition))
      |> put_param("OfferType", Keyword.get(opts, :offer_type))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/price", params: params)
  end

  @spec get_competitive_pricing(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_competitive_pricing(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    item_type = Keyword.fetch!(opts, :item_type)

    params =
      %{}
      |> put_param("MarketplaceId", marketplace_id)
      |> put_param("ItemType", item_type)
      |> put_csv_param("Asins", Keyword.get(opts, :asins))
      |> put_csv_param("Skus", Keyword.get(opts, :skus))
      |> put_param("CustomerType", Keyword.get(opts, :customer_type))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/competitivePrice", params: params)
  end

  @spec get_listing_offers(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_listing_offers(%Req.Request{} = req, seller_sku, opts)
      when is_binary(seller_sku) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    item_condition = Keyword.fetch!(opts, :item_condition)

    params =
      %{}
      |> put_param("MarketplaceId", marketplace_id)
      |> put_param("ItemCondition", item_condition)
      |> put_param("CustomerType", Keyword.get(opts, :customer_type))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/listings/#{path_segment(seller_sku)}/offers",
      params: params
    )
  end

  @spec get_item_offers(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_offers(%Req.Request{} = req, asin, opts)
      when is_binary(asin) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    item_condition = Keyword.fetch!(opts, :item_condition)

    params =
      %{}
      |> put_param("MarketplaceId", marketplace_id)
      |> put_param("ItemCondition", item_condition)
      |> put_param("CustomerType", Keyword.get(opts, :customer_type))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(asin)}/offers",
      params: params
    )
  end

  @spec get_item_offers_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_offers_batch(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/batches/items/offers",
      json: payload
    )
  end

  @spec get_listing_offers_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_listing_offers_batch(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/batches/listings/offers",
      json: payload
    )
  end

  @spec get_featured_offer_expected_price_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  @deprecated "Use ReqAmazon.SpApi.PricingV20220501.get_featured_offer_expected_price_batch/2 instead."
  defdelegate get_featured_offer_expected_price_batch(req, payload), to: PricingV20220501

  @spec get_competitive_summary(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  @deprecated "Use ReqAmazon.SpApi.PricingV20220501.get_competitive_summary/2 instead."
  defdelegate get_competitive_summary(req, payload), to: PricingV20220501
end
