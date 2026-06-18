defmodule ReqAmazon.SpApi.Orders do
  @moduledoc """
  Orders v0 operations.
  """

  import ReqAmazon

  @base_path "/orders/v0"

  @spec list_orders(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_orders(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("MarketplaceIds", marketplace_ids)
      |> put_param("CreatedAfter", Keyword.get(opts, :created_after))
      |> put_param("CreatedBefore", Keyword.get(opts, :created_before))
      |> put_csv_param("OrderStatuses", Keyword.get(opts, :order_statuses))
      |> put_csv_param("FulfillmentChannels", Keyword.get(opts, :fulfillment_channels))
      |> put_param("NextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/orders", params: params)
  end

  @spec get_order(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/orders/#{path_segment(order_id)}")
  end

  @spec get_order_buyer_info(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_buyer_info(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}/buyerInfo"
    )
  end

  @spec get_order_address(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_address(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}/address"
    )
  end

  @spec get_order_items(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_items(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    params =
      %{}
      |> put_param("NextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}/orderItems",
      params: params
    )
  end

  @spec get_order_items_buyer_info(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_items_buyer_info(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    params =
      %{}
      |> put_param("NextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}/orderItems/buyerInfo",
      params: params
    )
  end

  @spec get_order_regulated_info(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_regulated_info(%Req.Request{} = req, order_id) when is_binary(order_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}/regulatedInfo"
    )
  end

  @spec confirm_shipment(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_shipment(%Req.Request{} = req, order_id, payload)
      when is_binary(order_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(order_id)}/shipmentConfirmation",
      json: payload
    )
  end
end
