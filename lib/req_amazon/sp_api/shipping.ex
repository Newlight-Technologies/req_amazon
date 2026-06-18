defmodule ReqAmazon.SpApi.Shipping do
  @moduledoc """
  Shipping v2 operations.
  """

  import ReqAmazon

  @base_path "/shipping/v2"

  @spec get_rates(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_rates(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipments/rates", json: payload)
  end

  @spec direct_purchase_shipment(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def direct_purchase_shipment(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/shipments/directPurchase",
      json: payload
    )
  end

  @spec purchase_shipment(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def purchase_shipment(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/shipments", json: payload)
  end

  @spec one_click_shipment(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def one_click_shipment(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/oneClickShipment", json: payload)
  end

  @spec get_tracking(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_tracking(%Req.Request{} = req, opts) when is_list(opts) do
    tracking_id = Keyword.fetch!(opts, :tracking_id)
    carrier_id = Keyword.fetch!(opts, :carrier_id)

    params =
      %{}
      |> put_param("trackingId", tracking_id)
      |> put_param("carrierId", carrier_id)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/tracking", params: params)
  end

  @spec get_shipment_documents(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipment_documents(%Req.Request{} = req, shipment_id, opts)
      when is_binary(shipment_id) and is_list(opts) do
    package_client_reference_id = Keyword.fetch!(opts, :package_client_reference_id)

    params =
      %{}
      |> put_param("packageClientReferenceId", package_client_reference_id)
      |> put_param("format", Keyword.get(opts, :format))
      |> put_param("dpi", Keyword.get(opts, :dpi))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/shipments/#{path_segment(shipment_id)}/documents",
      params: params
    )
  end

  @spec cancel_shipment(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_shipment(%Req.Request{} = req, shipment_id) when is_binary(shipment_id) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/shipments/#{path_segment(shipment_id)}/cancel"
    )
  end

  @spec get_additional_inputs(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_additional_inputs(%Req.Request{} = req, opts) when is_list(opts) do
    request_token = Keyword.fetch!(opts, :request_token)
    rate_id = Keyword.fetch!(opts, :rate_id)

    params =
      %{}
      |> put_param("requestToken", request_token)
      |> put_param("rateId", rate_id)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/shipments/additionalInputs/schema",
      params: params
    )
  end

  @spec get_collection_form(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_collection_form(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/collectionForms", json: payload)
  end

  @spec get_unmanifested_shipments(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_unmanifested_shipments(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :put, "#{@base_path}/unmanifestedShipments", json: payload)
  end

  @spec get_access_points(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_access_points(%Req.Request{} = req, opts) when is_list(opts) do
    access_point_types = Keyword.fetch!(opts, :access_point_types)
    country_code = Keyword.fetch!(opts, :country_code)
    postal_code = Keyword.fetch!(opts, :postal_code)

    params =
      %{}
      |> put_csv_param("accessPointTypes", access_point_types)
      |> put_param("countryCode", country_code)
      |> put_param("postalCode", postal_code)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/accessPoints", params: params)
  end
end
