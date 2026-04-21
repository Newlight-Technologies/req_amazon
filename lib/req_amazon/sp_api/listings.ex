defmodule ReqAmazon.SpApi.Listings do
  @moduledoc """
  Listings Items v2021-08-01 operations.
  """

  import ReqAmazon

  @base_path "/listings/2021-08-01"

  @spec get_listings_item(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_listings_item(%Req.Request{} = req, seller_id, sku, opts)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_csv_param("includedData", Keyword.get(opts, :included_data))
      |> put_param("issueLocale", Keyword.get(opts, :issue_locale))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: params
    )
  end

  @spec put_listings_item(Req.Request.t(), String.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def put_listings_item(%Req.Request{} = req, seller_id, sku, opts, payload)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("issueLocale", Keyword.get(opts, :issue_locale))

    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: params,
      json: payload
    )
  end

  @spec patch_listings_item(Req.Request.t(), String.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def patch_listings_item(%Req.Request{} = req, seller_id, sku, opts, payload)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("issueLocale", Keyword.get(opts, :issue_locale))

    ReqAmazon.SpApi.request(
      req,
      :patch,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: params,
      json: payload
    )
  end

  @spec delete_listings_item(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def delete_listings_item(%Req.Request{} = req, seller_id, sku, opts)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("issueLocale", Keyword.get(opts, :issue_locale))

    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: params
    )
  end

  @spec search_listings_items(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_listings_items(%Req.Request{} = req, seller_id, opts)
      when is_binary(seller_id) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_csv_param("includedData", Keyword.get(opts, :included_data))
      |> put_csv_param("identifiers", Keyword.get(opts, :identifiers))
      |> put_param("identifiersType", Keyword.get(opts, :identifiers_type))
      |> put_param("issueLocale", Keyword.get(opts, :issue_locale))
      |> put_param("pageToken", Keyword.get(opts, :page_token))
      |> put_param("pageSize", Keyword.get(opts, :page_size))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(seller_id)}",
      params: params
    )
  end

  @spec get_listings_restrictions(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_listings_restrictions(%Req.Request{} = req, opts) when is_list(opts) do
    asin = Keyword.fetch!(opts, :asin)
    seller_id = Keyword.fetch!(opts, :seller_id)
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_param("asin", asin)
      |> put_param("sellerId", seller_id)
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("conditionType", Keyword.get(opts, :condition_type))
      |> put_param("reasonLocale", Keyword.get(opts, :reason_locale))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/restrictions", params: params)
  end
end
