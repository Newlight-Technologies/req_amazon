defmodule ReqAmazon.SpApi.Replenishment do
  @moduledoc """
  Replenishment v2022-11-07 operations.
  """

  @base_path "/replenishment/2022-11-07"

  @spec get_selling_partner_metrics(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_selling_partner_metrics(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/sellingPartners/metrics/search",
      json: payload
    )
  end

  @spec list_offer_metrics(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_offer_metrics(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/offers/metrics/search", json: payload)
  end

  @spec list_offers(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_offers(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/offers/search", json: payload)
  end
end
