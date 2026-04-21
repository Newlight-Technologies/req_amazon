defmodule ReqAmazon.SpApi.CatalogItems do
  @moduledoc """
  Catalog Items v2022-04-01 operations.
  """

  import ReqAmazon

  @base_path "/catalog/2022-04-01/items"

  @spec search_catalog_items(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_catalog_items(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    keywords = Keyword.get(opts, :keywords)
    asin_list = Keyword.get(opts, :asin_list)
    page_token = Keyword.get(opts, :page_token)

    cond do
      keywords && asin_list ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception("provide either :keywords or :asin_list, not both")
         )}

      is_nil(page_token) && is_nil(keywords) && is_nil(asin_list) ->
        {:error,
         ReqAmazon.SpApi.Error.wrap(
           ArgumentError.exception("one of :keywords, :asin_list, or :page_token is required")
         )}

      true ->
        params =
          %{}
          |> put_csv_param("marketplaceIds", marketplace_ids)
          |> put_csv_param("includedData", Keyword.get(opts, :included_data))
          |> put_param("pageToken", page_token)
          |> maybe_put_catalog_query(keywords, asin_list)

        ReqAmazon.SpApi.request(req, :get, @base_path, params: params)
    end
  end

  @spec get_catalog_item(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_catalog_item(%Req.Request{} = req, asin, opts)
      when is_binary(asin) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_csv_param("includedData", Keyword.get(opts, :included_data))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/#{path_segment(asin)}", params: params)
  end

  defp maybe_put_catalog_query(params, keywords, nil) when is_list(keywords) do
    put_csv_param(params, "keywords", keywords)
  end

  defp maybe_put_catalog_query(params, nil, asin_list) when is_list(asin_list) do
    params
    |> put_csv_param("identifiers", asin_list)
    |> put_param("identifiersType", "ASIN")
  end

  defp maybe_put_catalog_query(params, _keywords, _asin_list), do: params
end
