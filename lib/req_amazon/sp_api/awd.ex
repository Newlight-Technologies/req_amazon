defmodule ReqAmazon.SpApi.Awd do
  @moduledoc """
  Amazon Warehousing and Distribution v2024-05-09 operations.
  """

  import ReqAmazon

  @base_path "/awd/2024-05-09"

  @spec list_inbound_shipments(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_inbound_shipments(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("sortBy", Keyword.get(opts, :sort_by))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("shipmentStatus", Keyword.get(opts, :shipment_status))
      |> put_param("updatedAfter", Keyword.get(opts, :updated_after))
      |> put_param("updatedBefore", Keyword.get(opts, :updated_before))
      |> put_param("maxResults", Keyword.get(opts, :max_results))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/inboundShipments", params: params)
  end

  @spec get_inbound_shipment(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inbound_shipment(%Req.Request{} = req, shipment_id) when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundShipments/#{path_segment(shipment_id)}"
    )
  end

  @spec create_inbound_order(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_inbound_order(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/inboundOrders", json: payload)
  end

  @spec get_inbound_order(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inbound_order(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundOrders/#{path_segment(order_id)}"
    )
  end

  @spec update_inbound_order(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_inbound_order(%Req.Request{} = req, order_id, payload)
      when is_binary(order_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/inboundOrders/#{path_segment(order_id)}",
      json: payload
    )
  end

  @spec cancel_inbound_order(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_inbound_order(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundOrders/#{path_segment(order_id)}/cancellation"
    )
  end

  @spec confirm_inbound_order(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_inbound_order(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundOrders/#{path_segment(order_id)}/confirmation"
    )
  end

  @spec get_inbound_shipment_labels(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inbound_shipment_labels(%Req.Request{} = req, shipment_id, opts \\ [])
      when is_binary(shipment_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageType", Keyword.get(opts, :page_type))
      |> put_param("formatType", Keyword.get(opts, :format_type))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundShipments/#{path_segment(shipment_id)}/labels",
      params: params
    )
  end

  @spec get_inbound_shipment_label_page_types(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inbound_shipment_label_page_types(%Req.Request{} = req, shipment_id)
      when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundShipments/#{path_segment(shipment_id)}/labelPageTypes"
    )
  end

  @spec update_transport(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_transport(%Req.Request{} = req, shipment_id, payload)
      when is_binary(shipment_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/inboundShipments/#{path_segment(shipment_id)}/transport",
      json: payload
    )
  end

  @spec check_inbound_eligibility(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def check_inbound_eligibility(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/inboundEligibility", json: payload)
  end

  @spec get_inventory(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inventory(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("sku", Keyword.get(opts, :sku))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("details", Keyword.get(opts, :details))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("maxResults", Keyword.get(opts, :max_results))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/inventory", params: params)
  end
end
