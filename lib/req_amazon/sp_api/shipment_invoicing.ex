defmodule ReqAmazon.SpApi.ShipmentInvoicing do
  @moduledoc """
  Shipment Invoicing v0 operations (Brazil FBA outbound).
  """

  import ReqAmazon

  @base_path "/fba/outbound/brazil/v0"

  @spec get_shipment_details(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipment_details(%Req.Request{} = req, shipment_id) when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/shipments/#{path_segment(shipment_id)}"
    )
  end

  @spec submit_invoice(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_invoice(%Req.Request{} = req, shipment_id, payload)
      when is_binary(shipment_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/shipments/#{path_segment(shipment_id)}/invoice",
      json: payload
    )
  end

  @spec get_invoice_status(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_invoice_status(%Req.Request{} = req, shipment_id) when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/shipments/#{path_segment(shipment_id)}/invoice/status"
    )
  end
end
