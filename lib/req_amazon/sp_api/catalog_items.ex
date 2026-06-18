defmodule ReqAmazon.SpApi.CatalogItems do
  @moduledoc """
  Catalog Items v2022-04-01 operations.
  """

  import ReqAmazon

  @base_path "/catalog/2022-04-01/items"

  @spec search_catalog_items(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_catalog_items(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    keywords = Keyword.get(opts, :keywords)
    page_token = Keyword.get(opts, :page_token)
    identifiers = catalog_identifiers(opts)
    identifiers_type = catalog_identifiers_type(opts)
    seller_id = Keyword.get(opts, :seller_id)

    cond do
      keywords && identifiers ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception(
             "provide either :keywords or :identifiers/:asin_list, not both"
           )
         )}

      is_nil(page_token) && is_nil(keywords) && is_nil(identifiers) ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception(
             "one of :keywords, :identifiers/:asin_list, or :page_token is required"
           )
         )}

      not is_nil(identifiers) && is_nil(identifiers_type) ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception(":identifiers_type is required when :identifiers is provided")
         )}

      identifiers_type == "SKU" && is_nil(seller_id) ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception(":seller_id is required when :identifiers_type is \"SKU\"")
         )}

      identifiers &&
          (Keyword.get(opts, :brand_names) || Keyword.get(opts, :classification_ids) ||
             Keyword.get(opts, :keywords_locale)) ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception(
             ":brand_names, :classification_ids, and :keywords_locale cannot be combined with identifiers"
           )
         )}

      true ->
        params =
          %{}
          |> put_csv_param("marketplaceIds", marketplace_ids)
          |> put_csv_param("includedData", Keyword.get(opts, :included_data))
          |> put_param("locale", Keyword.get(opts, :locale))
          |> put_param("sellerId", seller_id)
          |> put_param("pageToken", page_token)
          |> put_param("pageSize", Keyword.get(opts, :page_size))
          |> maybe_put_catalog_query(opts, keywords, identifiers, identifiers_type)

        ReqAmazon.SpApi.request(req, :get, @base_path, params: params)
    end
  end

  @spec get_catalog_item(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_catalog_item(%Req.Request{} = req, asin, opts)
      when is_binary(asin) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_csv_param("includedData", Keyword.get(opts, :included_data))
      |> put_param("locale", Keyword.get(opts, :locale))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/#{path_segment(asin)}", params: params)
  end

  defp maybe_put_catalog_query(params, opts, keywords, nil, _identifiers_type)
       when is_list(keywords) do
    params
    |> put_csv_param("keywords", keywords)
    |> put_csv_param("brandNames", Keyword.get(opts, :brand_names))
    |> put_csv_param("classificationIds", Keyword.get(opts, :classification_ids))
    |> put_param("keywordsLocale", Keyword.get(opts, :keywords_locale))
  end

  defp maybe_put_catalog_query(params, _opts, nil, identifiers, identifiers_type)
       when is_list(identifiers) do
    params
    |> put_csv_param("identifiers", identifiers)
    |> put_param("identifiersType", identifiers_type)
  end

  defp maybe_put_catalog_query(params, _opts, _keywords, _identifiers, _identifiers_type),
    do: params

  defp catalog_identifiers(opts) do
    cond do
      identifiers = Keyword.get(opts, :identifiers) ->
        identifiers

      asin_list = Keyword.get(opts, :asin_list) ->
        asin_list

      true ->
        nil
    end
  end

  defp catalog_identifiers_type(opts) do
    cond do
      identifiers_type = Keyword.get(opts, :identifiers_type) ->
        identifiers_type

      Keyword.get(opts, :asin_list) ->
        "ASIN"

      true ->
        nil
    end
  end
end
