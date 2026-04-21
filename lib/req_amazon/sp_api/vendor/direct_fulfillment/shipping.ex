defmodule ReqAmazon.SpApi.Vendor.DirectFulfillment.Shipping do
  @moduledoc """
  Vendor Direct Fulfillment Shipping v2021-12-28 operations.
  """

  import ReqAmazon

  @base_path "/vendor/directFulfillment/shipping/2021-12-28"

  @spec get_shipping_labels(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipping_labels(%Req.Request{} = req, opts) when is_list(opts) do
    created_after = Keyword.fetch!(opts, :created_after)
    created_before = Keyword.fetch!(opts, :created_before)

    params =
      %{}
      |> put_param("createdAfter", created_after)
      |> put_param("createdBefore", created_before)
      |> put_param("shipFromPartyId", Keyword.get(opts, :ship_from_party_id))
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/shippingLabels", params: params)
  end

  @spec get_shipping_label(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipping_label(%Req.Request{} = req, purchase_order_number)
      when is_binary(purchase_order_number) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/shippingLabels/#{path_segment(purchase_order_number)}"
    )
  end

  @spec submit_shipping_label_request(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_shipping_label_request(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shippingLabels", json: payload)
  end

  @spec submit_shipment_confirmations(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_shipment_confirmations(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipmentConfirmations", json: payload)
  end

  @spec submit_shipment_status_updates(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_shipment_status_updates(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipmentStatusUpdates", json: payload)
  end

  @spec get_customer_invoices(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_customer_invoices(%Req.Request{} = req, opts) when is_list(opts) do
    created_after = Keyword.fetch!(opts, :created_after)
    created_before = Keyword.fetch!(opts, :created_before)

    params =
      %{}
      |> put_param("createdAfter", created_after)
      |> put_param("createdBefore", created_before)
      |> put_param("shipFromPartyId", Keyword.get(opts, :ship_from_party_id))
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/customerInvoices", params: params)
  end

  @spec get_customer_invoice(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_customer_invoice(%Req.Request{} = req, purchase_order_number)
      when is_binary(purchase_order_number) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/customerInvoices/#{path_segment(purchase_order_number)}"
    )
  end

  @spec get_packing_slips(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_packing_slips(%Req.Request{} = req, opts) when is_list(opts) do
    created_after = Keyword.fetch!(opts, :created_after)
    created_before = Keyword.fetch!(opts, :created_before)

    params =
      %{}
      |> put_param("createdAfter", created_after)
      |> put_param("createdBefore", created_before)
      |> put_param("shipFromPartyId", Keyword.get(opts, :ship_from_party_id))
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/packingSlips", params: params)
  end

  @spec get_packing_slip(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_packing_slip(%Req.Request{} = req, purchase_order_number)
      when is_binary(purchase_order_number) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/packingSlips/#{path_segment(purchase_order_number)}"
    )
  end
end
