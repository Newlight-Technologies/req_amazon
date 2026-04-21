defmodule ReqAmazon.SpApi.FulfillmentOutbound do
  @moduledoc """
  Fulfillment Outbound v2020-07-01 operations.
  """

  import ReqAmazon

  @base_path "/fba/outbound/2020-07-01"

  @spec get_fulfillment_preview(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_fulfillment_preview(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/fulfillmentOrders/preview", json: payload)
  end

  @spec list_delivery_offers(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_delivery_offers(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/fulfillmentOrders/deliveryOffers",
      json: payload
    )
  end

  @spec create_fulfillment_order(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_fulfillment_order(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/fulfillmentOrders", json: payload)
  end

  @spec get_fulfillment_order(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_fulfillment_order(%Req.Request{} = req, seller_fulfillment_order_id)
      when is_binary(seller_fulfillment_order_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/fulfillmentOrders/#{path_segment(seller_fulfillment_order_id)}"
    )
  end

  @spec update_fulfillment_order(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_fulfillment_order(%Req.Request{} = req, seller_fulfillment_order_id, payload)
      when is_binary(seller_fulfillment_order_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/fulfillmentOrders/#{path_segment(seller_fulfillment_order_id)}",
      json: payload
    )
  end

  @spec list_all_fulfillment_orders(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_all_fulfillment_orders(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("queryStartDate", Keyword.get(opts, :query_start_date))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/fulfillmentOrders", params: params)
  end

  @spec cancel_fulfillment_order(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_fulfillment_order(%Req.Request{} = req, seller_fulfillment_order_id)
      when is_binary(seller_fulfillment_order_id) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/fulfillmentOrders/#{path_segment(seller_fulfillment_order_id)}/cancel"
    )
  end

  @spec get_package_tracking_details(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_package_tracking_details(%Req.Request{} = req, package_number)
      when is_binary(package_number) do
    params =
      %{}
      |> put_param("packageNumber", package_number)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/tracking", params: params)
  end

  @spec get_return_reason_codes(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_return_reason_codes(%Req.Request{} = req, opts) when is_list(opts) do
    seller_sku = Keyword.fetch!(opts, :seller_sku)

    params =
      %{}
      |> put_param("sellerSku", seller_sku)
      |> put_param("marketplaceId", Keyword.get(opts, :marketplace_id))
      |> put_param("sellerFulfillmentOrderId", Keyword.get(opts, :seller_fulfillment_order_id))
      |> put_param("language", Keyword.get(opts, :language))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/returnReasonCodes", params: params)
  end

  @spec create_fulfillment_return(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_fulfillment_return(%Req.Request{} = req, seller_fulfillment_order_id, payload)
      when is_binary(seller_fulfillment_order_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/fulfillmentOrders/#{path_segment(seller_fulfillment_order_id)}/return",
      json: payload
    )
  end

  @spec get_features(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_features(%Req.Request{} = req, marketplace_id) when is_binary(marketplace_id) do
    params = %{} |> put_param("marketplaceId", marketplace_id)
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/features", params: params)
  end

  @spec get_feature_inventory(Req.Request.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_feature_inventory(%Req.Request{} = req, feature_name, marketplace_id, opts \\ [])
      when is_binary(feature_name) and is_binary(marketplace_id) and is_list(opts) do
    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/features/inventory/#{path_segment(feature_name)}",
      params: params
    )
  end

  @spec get_feature_sku(Req.Request.t(), String.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_feature_sku(%Req.Request{} = req, feature_name, seller_sku, marketplace_id)
      when is_binary(feature_name) and is_binary(seller_sku) and is_binary(marketplace_id) do
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/features/inventory/#{path_segment(feature_name)}/#{path_segment(seller_sku)}",
      params: params
    )
  end
end
