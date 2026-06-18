defmodule ReqAmazon.SpApi.ListingsRestrictions do
  @moduledoc """
  Listings Restrictions v2021-08-01 operations.
  """

  import ReqAmazon

  @base_path "/listings/2021-08-01/restrictions"

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
      |> put_param("productType", Keyword.get(opts, :product_type))

    ReqAmazon.SpApi.request(req, :get, @base_path, params: params)
  end
end
