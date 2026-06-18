defmodule ReqAmazon.SpApi.EasyShip do
  @moduledoc """
  Easy Ship v2022-03-23 operations.
  """

  import ReqAmazon

  @base_path "/easyShip/2022-03-23"

  @spec list_handover_slots(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_handover_slots(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/timeSlot", json: payload)
  end

  @spec get_scheduled_package(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_scheduled_package(%Req.Request{} = req, opts) when is_list(opts) do
    amazon_order_id = Keyword.fetch!(opts, :amazon_order_id)
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)

    params =
      %{}
      |> put_param("amazonOrderId", amazon_order_id)
      |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/package", params: params)
  end

  @spec create_scheduled_package(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_scheduled_package(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/package", json: payload)
  end

  @spec update_scheduled_packages(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_scheduled_packages(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :patch, "#{@base_path}/package", json: payload)
  end

  @spec create_scheduled_package_bulk(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_scheduled_package_bulk(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/packages/bulk", json: payload)
  end
end
