defmodule ReqAmazon.SpApi.ProductTypeDefinitions do
  @moduledoc """
  Product Type Definitions v2020-09-01 operations.
  """

  import ReqAmazon
  alias ReqAmazon.SpApi.Error

  @base_path "/definitions/2020-09-01/productTypes"

  @spec search_definitions_product_types(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
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
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
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

  @spec fetch_schema(map(), keyword()) :: {:ok, term()} | {:error, Error.t()}
  def fetch_schema(%{} = product_type_definition, opts \\ []) when is_list(opts) do
    product_type_definition
    |> fetch_link_url(["schema", "link"])
    |> fetch_link_resource(opts)
  end

  @spec fetch_meta_schema(map(), keyword()) :: {:ok, term()} | {:error, Error.t()}
  def fetch_meta_schema(%{} = product_type_definition, opts \\ []) when is_list(opts) do
    product_type_definition
    |> fetch_link_url(["metaSchema", "link"])
    |> fetch_link_resource(opts)
  end

  @spec fetch_link_resource(String.t() | map() | nil, keyword()) ::
          {:ok, term()} | {:error, Error.t()}
  def fetch_link_resource(url_or_link, opts \\ [])

  def fetch_link_resource(url, opts) when is_binary(url) and is_list(opts) do
    request_opts = Keyword.merge([method: :get, url: url], opts)

    case Req.request(request_opts) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, Error.from_response(status, body)}

      {:error, error} ->
        {:error, Error.wrap(error)}
    end
  end

  def fetch_link_resource(%{"resource" => url}, opts), do: fetch_link_resource(url, opts)
  def fetch_link_resource(%{resource: url}, opts), do: fetch_link_resource(url, opts)

  def fetch_link_resource(_missing, _opts) do
    {:error,
     Error.from_response(nil, %{
       "errors" => [
         %{
           "code" => "MissingSchemaLink",
           "message" => "Product type definition did not include a schema link resource"
         }
       ]
     })}
  end

  defp fetch_link_url(product_type_definition, path) do
    case get_in(product_type_definition, path) do
      %{"resource" => url} -> url
      link -> link
    end
  end
end
