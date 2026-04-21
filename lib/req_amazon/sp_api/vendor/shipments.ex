defmodule ReqAmazon.SpApi.Vendor.Shipments do
  @moduledoc """
  Vendor Shipments (Retail Procurement) v1 operations.
  """

  import ReqAmazon

  @base_path "/vendor/shipping/v1"

  @spec submit_shipment_confirmations(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_shipment_confirmations(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipmentConfirmations", json: payload)
  end

  @spec submit_shipments(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_shipments(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipments", json: payload)
  end

  @spec get_shipment_details(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipment_details(%Req.Request{} = req, opts) when is_list(opts) do
    params =
      %{}
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("createdAfter", Keyword.get(opts, :created_after))
      |> put_param("createdBefore", Keyword.get(opts, :created_before))
      |> put_param("shipmentConfirmedBefore", Keyword.get(opts, :shipment_confirmed_before))
      |> put_param("shipmentConfirmedAfter", Keyword.get(opts, :shipment_confirmed_after))
      |> put_param("packageLabelCreatedBefore", Keyword.get(opts, :package_label_created_before))
      |> put_param("packageLabelCreatedAfter", Keyword.get(opts, :package_label_created_after))
      |> put_param("shippedBefore", Keyword.get(opts, :shipped_before))
      |> put_param("shippedAfter", Keyword.get(opts, :shipped_after))
      |> put_param("estimatedDeliveryBefore", Keyword.get(opts, :estimated_delivery_before))
      |> put_param("estimatedDeliveryAfter", Keyword.get(opts, :estimated_delivery_after))
      |> put_param("shipmentDeliveryBefore", Keyword.get(opts, :shipment_delivery_before))
      |> put_param("shipmentDeliveryAfter", Keyword.get(opts, :shipment_delivery_after))
      |> put_param("requestedPickUpBefore", Keyword.get(opts, :requested_pick_up_before))
      |> put_param("requestedPickUpAfter", Keyword.get(opts, :requested_pick_up_after))
      |> put_param("scheduledPickUpBefore", Keyword.get(opts, :scheduled_pick_up_before))
      |> put_param("scheduledPickUpAfter", Keyword.get(opts, :scheduled_pick_up_after))
      |> put_param("currentShipmentStatus", Keyword.get(opts, :current_shipment_status))
      |> put_param("vendorShipmentIdentifier", Keyword.get(opts, :vendor_shipment_identifier))
      |> put_param("buyerReferenceNumber", Keyword.get(opts, :buyer_reference_number))
      |> put_param("buyerWarehouseCode", Keyword.get(opts, :buyer_warehouse_code))
      |> put_param("sellerWarehouseCode", Keyword.get(opts, :seller_warehouse_code))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/shipments", params: params)
  end

  @spec get_transport_labels(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_transport_labels(%Req.Request{} = req, opts) when is_list(opts) do
    params =
      %{}
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("labelCreatedAfter", Keyword.get(opts, :label_created_after))
      |> put_param("labelCreatedBefore", Keyword.get(opts, :label_created_before))
      |> put_param("buyerReferenceNumber", Keyword.get(opts, :buyer_reference_number))
      |> put_param("vendorShipmentIdentifier", Keyword.get(opts, :vendor_shipment_identifier))
      |> put_param("sellerWarehouseCode", Keyword.get(opts, :seller_warehouse_code))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/transportLabels", params: params)
  end
end
