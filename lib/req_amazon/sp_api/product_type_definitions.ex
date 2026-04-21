defmodule ReqAmazon.SpApi.ProductTypeDefinitions do
  @moduledoc """
  Product Type Definitions v2020-09-01 operations.
  """

  import ReqAmazon

  @base_path "/definitions/2020-09-01/productTypes"

  @spec search_definitions_product_types(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_definitions_product_types(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("keywords", Keyword.get(opts, :keywords))
      |> put_param("itemName", Keyword.get(opts, :item_name))
      |> put_param("locale", Keyword.get(opts, :locale))
      |> put_param("searchLocale", Keyword.get(opts, :search_locale))

    ReqAmazon.SpApi.request(req, :get, @base_path, params: params)
  end

  @spec get_definitions_product_type(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_definitions_product_type(%Req.Request{} = req, product_type, opts)
      when is_binary(product_type) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("sellerId", Keyword.get(opts, :seller_id))
      |> put_param("productTypeVersion", Keyword.get(opts, :product_type_version))
      |> put_param("requirements", Keyword.get(opts, :requirements))
      |> put_param("requirementsEnforced", Keyword.get(opts, :requirements_enforced))
      |> put_param("locale", Keyword.get(opts, :locale))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/#{path_segment(product_type)}",
      params: params
    )
  end
end
