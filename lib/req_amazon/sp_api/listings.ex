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
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: item_read_params(opts)
    )
  end

  @spec put_listings_item(Req.Request.t(), String.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def put_listings_item(%Req.Request{} = req, seller_id, sku, opts, payload)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: item_mutation_params(opts),
      json: payload
    )
  end

  @spec patch_listings_item(Req.Request.t(), String.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def patch_listings_item(%Req.Request{} = req, seller_id, sku, opts, payload)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :patch,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: item_mutation_params(opts),
      json: payload
    )
  end

  @spec delete_listings_item(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def delete_listings_item(%Req.Request{} = req, seller_id, sku, opts)
      when is_binary(seller_id) and is_binary(sku) and is_list(opts) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/items/#{path_segment(seller_id)}/#{path_segment(sku)}",
      params: item_base_params(opts)
    )
  end

  @spec search_listings_items(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_listings_items(%Req.Request{} = req, seller_id, opts)
      when is_binary(seller_id) and is_list(opts) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(seller_id)}",
      params: search_params(opts)
    )
  end

  @spec get_listings_restrictions(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_listings_restrictions(%Req.Request{} = req, opts) when is_list(opts) do
    ReqAmazon.SpApi.ListingsRestrictions.get_listings_restrictions(req, opts)
  end

  defp item_read_params(opts) do
    opts
    |> item_base_params()
    |> put_csv_param("includedData", Keyword.get(opts, :included_data))
  end

  defp item_mutation_params(opts) do
    opts
    |> item_read_params()
    |> put_param("mode", Keyword.get(opts, :mode))
  end

  defp item_base_params(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    %{}
    |> put_csv_param("marketplaceIds", marketplace_ids)
    |> put_param("issueLocale", Keyword.get(opts, :issue_locale))
  end

  defp search_params(opts) do
    opts
    |> item_read_params()
    |> put_csv_param("identifiers", Keyword.get(opts, :identifiers))
    |> put_param("identifiersType", Keyword.get(opts, :identifiers_type))
    |> put_param("variationParentSku", Keyword.get(opts, :variation_parent_sku))
    |> put_param("packageHierarchySku", Keyword.get(opts, :package_hierarchy_sku))
    |> put_csv_param("withIssueSeverity", Keyword.get(opts, :with_issue_severity))
    |> put_csv_param("withStatus", Keyword.get(opts, :with_status))
    |> put_csv_param("withoutStatus", Keyword.get(opts, :without_status))
    |> put_param("sortBy", Keyword.get(opts, :sort_by))
    |> put_param("sortOrder", Keyword.get(opts, :sort_order))
    |> put_param("pageToken", Keyword.get(opts, :page_token))
    |> put_param("pageSize", Keyword.get(opts, :page_size))
  end
end
