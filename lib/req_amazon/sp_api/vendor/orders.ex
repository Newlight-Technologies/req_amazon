defmodule ReqAmazon.SpApi.Vendor.Orders do
  @moduledoc """
  Vendor Orders (Retail Procurement) v1 operations.
  """

  import ReqAmazon

  @base_path "/vendor/orders/v1"

  @spec get_purchase_orders(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_purchase_orders(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("createdAfter", Keyword.get(opts, :created_after))
      |> put_param("createdBefore", Keyword.get(opts, :created_before))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("includeDetails", Keyword.get(opts, :include_details))
      |> put_param("changedAfter", Keyword.get(opts, :changed_after))
      |> put_param("changedBefore", Keyword.get(opts, :changed_before))
      |> put_param("poItemState", Keyword.get(opts, :po_item_state))
      |> put_param("isPOChanged", Keyword.get(opts, :is_po_changed))
      |> put_param("purchaseOrderState", Keyword.get(opts, :purchase_order_state))
      |> put_param("orderingVendorCode", Keyword.get(opts, :ordering_vendor_code))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/purchaseOrders", params: params)
  end

  @spec get_purchase_order(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_purchase_order(%Req.Request{} = req, purchase_order_number)
      when is_binary(purchase_order_number) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/purchaseOrders/#{path_segment(purchase_order_number)}"
    )
  end

  @spec submit_acknowledgement(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_acknowledgement(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/acknowledgements", json: payload)
  end

  @spec get_purchase_orders_status(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_purchase_orders_status(%Req.Request{} = req, opts) when is_list(opts) do
    params =
      %{}
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("createdAfter", Keyword.get(opts, :created_after))
      |> put_param("createdBefore", Keyword.get(opts, :created_before))
      |> put_param("updatedAfter", Keyword.get(opts, :updated_after))
      |> put_param("updatedBefore", Keyword.get(opts, :updated_before))
      |> put_param("purchaseOrderNumber", Keyword.get(opts, :purchase_order_number))
      |> put_param("purchaseOrderStatus", Keyword.get(opts, :purchase_order_status))
      |> put_param("itemConfirmationStatus", Keyword.get(opts, :item_confirmation_status))
      |> put_param("orderingVendorCode", Keyword.get(opts, :ordering_vendor_code))
      |> put_param("shipToPartyId", Keyword.get(opts, :ship_to_party_id))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/purchaseOrdersStatus", params: params)
  end
end
