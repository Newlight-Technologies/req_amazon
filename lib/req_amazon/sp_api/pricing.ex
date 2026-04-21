defmodule ReqAmazon.SpApi.Pricing do
  @moduledoc """
  Product Pricing v0 and v2022-05-01 operations.
  """

  import ReqAmazon

  @base_path_v0 "/products/pricing/v0"
  @base_path_v1 "/batches/products/pricing/2022-05-01"

  # --- v0 endpoints ---

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

    ReqAmazon.SpApi.request(req, :get, "#{@base_path_v0}/price", params: params)
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

    ReqAmazon.SpApi.request(req, :get, "#{@base_path_v0}/competitivePrice", params: params)
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
      "#{@base_path_v0}/listings/#{path_segment(seller_sku)}/offers",
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
      "#{@base_path_v0}/items/#{path_segment(asin)}/offers",
      params: params
    )
  end

  @spec get_item_offers_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_offers_batch(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path_v0}/batches/items/offers",
      json: payload
    )
  end

  @spec get_listing_offers_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_listing_offers_batch(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path_v0}/batches/listings/offers",
      json: payload
    )
  end

  # --- v2022-05-01 batch endpoints ---

  @spec get_featured_offer_expected_price_batch(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_featured_offer_expected_price_batch(%Req.Request{} = req, payload)
      when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path_v1}/offer/featuredOfferExpectedPrice",
      json: payload
    )
  end

  @spec get_competitive_summary(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_competitive_summary(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path_v1}/items/competitiveSummary",
      json: payload
    )
  end
end
