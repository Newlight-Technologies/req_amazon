defmodule ReqAmazon.SpApi.Messaging do
  @moduledoc """
  Messaging v1 operations.
  """

  import ReqAmazon

  @base_path "/messaging/v1"

  @spec get_messaging_actions_for_order(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_messaging_actions_for_order(%Req.Request{} = req, amazon_order_id, opts)
      when is_binary(amazon_order_id) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}",
      params: params
    )
  end

  @spec confirm_customization_details(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def confirm_customization_details(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/confirmCustomizationDetails",
      params: params,
      json: payload
    )
  end

  @spec create_confirm_delivery_details(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_confirm_delivery_details(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/confirmDeliveryDetails",
      params: params,
      json: payload
    )
  end

  @spec create_legal_disclosure(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_legal_disclosure(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/legalDisclosure",
      params: params,
      json: payload
    )
  end

  @spec create_confirm_order_details(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_confirm_order_details(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/confirmOrderDetails",
      params: params,
      json: payload
    )
  end

  @spec create_confirm_service_details(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_confirm_service_details(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/confirmServiceDetails",
      params: params,
      json: payload
    )
  end

  @spec create_warranty(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_warranty(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/warranty",
      params: params,
      json: payload
    )
  end

  @spec get_attributes(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_attributes(%Req.Request{} = req, amazon_order_id, opts)
      when is_binary(amazon_order_id) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/attributes",
      params: params
    )
  end

  @spec create_digital_access_key(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_digital_access_key(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/digitalAccessKey",
      params: params,
      json: payload
    )
  end

  @spec create_unexpected_problem(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_unexpected_problem(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/unexpectedProblem",
      params: params,
      json: payload
    )
  end

  @spec send_invoice(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def send_invoice(%Req.Request{} = req, amazon_order_id, opts, payload)
      when is_binary(amazon_order_id) and is_list(opts) and is_map(payload) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/messages/invoice",
      params: params,
      json: payload
    )
  end
end
