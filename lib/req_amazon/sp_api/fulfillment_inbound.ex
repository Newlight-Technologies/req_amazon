defmodule ReqAmazon.SpApi.FulfillmentInbound do
  @moduledoc """
  Fulfillment Inbound v2024-03-20 operations.
  """

  import ReqAmazon

  @base_path "/inbound/fba/2024-03-20"

  @spec list_inbound_plans(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_inbound_plans(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))
      |> put_param("status", Keyword.get(opts, :status))
      |> put_param("sortBy", Keyword.get(opts, :sort_by))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/inboundPlans", params: params)
  end

  @spec create_inbound_plan(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_inbound_plan(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/inboundPlans", json: payload)
  end

  @spec get_inbound_plan(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inbound_plan(%Req.Request{} = req, inbound_plan_id) when is_binary(inbound_plan_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}"
    )
  end

  @spec list_inbound_plan_boxes(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_inbound_plan_boxes(%Req.Request{} = req, inbound_plan_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/boxes",
      params: params
    )
  end

  @spec cancel_inbound_plan(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_inbound_plan(%Req.Request{} = req, inbound_plan_id)
      when is_binary(inbound_plan_id) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/cancellation"
    )
  end

  @spec list_inbound_plan_items(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_inbound_plan_items(%Req.Request{} = req, inbound_plan_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/items",
      params: params
    )
  end

  @spec update_inbound_plan_name(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_inbound_plan_name(%Req.Request{} = req, inbound_plan_id, payload)
      when is_binary(inbound_plan_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/name",
      json: payload
    )
  end

  @spec set_packing_information(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def set_packing_information(%Req.Request{} = req, inbound_plan_id, payload)
      when is_binary(inbound_plan_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/packingInformation",
      json: payload
    )
  end

  @spec list_packing_options(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_packing_options(%Req.Request{} = req, inbound_plan_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/packingOptions",
      params: params
    )
  end

  @spec generate_packing_options(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def generate_packing_options(%Req.Request{} = req, inbound_plan_id)
      when is_binary(inbound_plan_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/packingOptions"
    )
  end

  @spec confirm_packing_option(Req.Request.t(), String.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_packing_option(%Req.Request{} = req, inbound_plan_id, packing_option_id)
      when is_binary(inbound_plan_id) and is_binary(packing_option_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/packingOptions/#{path_segment(packing_option_id)}/confirmation"
    )
  end

  @spec list_placement_options(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_placement_options(%Req.Request{} = req, inbound_plan_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/placementOptions",
      params: params
    )
  end

  @spec generate_placement_options(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def generate_placement_options(%Req.Request{} = req, inbound_plan_id, payload)
      when is_binary(inbound_plan_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/placementOptions",
      json: payload
    )
  end

  @spec confirm_placement_option(Req.Request.t(), String.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_placement_option(%Req.Request{} = req, inbound_plan_id, placement_option_id)
      when is_binary(inbound_plan_id) and is_binary(placement_option_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/placementOptions/#{path_segment(placement_option_id)}/confirmation"
    )
  end

  @spec get_shipment(Req.Request.t(), String.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipment(%Req.Request{} = req, inbound_plan_id, shipment_id)
      when is_binary(inbound_plan_id) and is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}"
    )
  end

  @spec list_shipment_boxes(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_shipment_boxes(%Req.Request{} = req, inbound_plan_id, shipment_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/boxes",
      params: params
    )
  end

  @spec list_delivery_window_options(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_delivery_window_options(%Req.Request{} = req, inbound_plan_id, shipment_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/deliveryWindowOptions",
      params: params
    )
  end

  @spec generate_delivery_window_options(Req.Request.t(), String.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def generate_delivery_window_options(%Req.Request{} = req, inbound_plan_id, shipment_id)
      when is_binary(inbound_plan_id) and is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/deliveryWindowOptions"
    )
  end

  @spec confirm_delivery_window_options(Req.Request.t(), String.t(), String.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_delivery_window_options(
        %Req.Request{} = req,
        inbound_plan_id,
        shipment_id,
        delivery_window_option_id
      )
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and
             is_binary(delivery_window_option_id) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/deliveryWindowOptions/#{path_segment(delivery_window_option_id)}/confirmation"
    )
  end

  @spec list_transportation_options(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_transportation_options(
        %Req.Request{} = req,
        inbound_plan_id,
        shipment_id,
        opts \\ []
      )
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/transportationOptions",
      params: params
    )
  end

  @spec generate_transportation_options(Req.Request.t(), String.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def generate_transportation_options(
        %Req.Request{} = req,
        inbound_plan_id,
        shipment_id,
        payload
      )
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/transportationOptions",
      json: payload
    )
  end

  @spec confirm_transportation_options(Req.Request.t(), String.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_transportation_options(
        %Req.Request{} = req,
        inbound_plan_id,
        shipment_id,
        payload
      )
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/transportationOptions/confirmation",
      json: payload
    )
  end

  @spec get_labels(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_labels(%Req.Request{} = req, inbound_plan_id, shipment_id, opts \\ [])
      when is_binary(inbound_plan_id) and is_binary(shipment_id) and is_list(opts) do
    params =
      %{}
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/inboundPlans/#{path_segment(inbound_plan_id)}/shipments/#{path_segment(shipment_id)}/labels",
      params: params
    )
  end

  @spec get_inbound_operation_status(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inbound_operation_status(%Req.Request{} = req, operation_id)
      when is_binary(operation_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/operations/#{path_segment(operation_id)}"
    )
  end
end
