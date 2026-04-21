defmodule ReqAmazon.SpApi.ProductFees do
  @moduledoc """
  Product Fees v0 operations.
  """

  import ReqAmazon

  @base_path "/products/fees/v0"

  @spec get_my_fees_estimate_for_sku(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_my_fees_estimate_for_sku(%Req.Request{} = req, seller_sku, payload)
      when is_binary(seller_sku) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/listings/#{path_segment(seller_sku)}/feesEstimate",
      json: payload
    )
  end

  @spec get_my_fees_estimate_for_asin(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_my_fees_estimate_for_asin(%Req.Request{} = req, asin, payload)
      when is_binary(asin) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/items/#{path_segment(asin)}/feesEstimate",
      json: payload
    )
  end

  @spec get_my_fees_estimates(Req.Request.t(), list(map())) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_my_fees_estimates(%Req.Request{} = req, payload) when is_list(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/feesEstimate", json: payload)
  end
end
