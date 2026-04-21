defmodule ReqAmazon.SpApi.MerchantFulfillment do
  @moduledoc """
  Merchant Fulfillment v0 operations.
  """

  import ReqAmazon

  @base_path "/mfn/v0"

  @spec get_eligible_shipment_services(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_eligible_shipment_services(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/eligibleShippingServices", json: payload)
  end

  @spec get_shipment(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipment(%Req.Request{} = req, shipment_id) when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/shipments/#{path_segment(shipment_id)}")
  end

  @spec cancel_shipment(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_shipment(%Req.Request{} = req, shipment_id) when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/shipments/#{path_segment(shipment_id)}"
    )
  end

  @spec create_shipment(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_shipment(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipments", json: payload)
  end

  @spec get_additional_seller_inputs(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_additional_seller_inputs(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/additionalSellerInputs", json: payload)
  end
end
