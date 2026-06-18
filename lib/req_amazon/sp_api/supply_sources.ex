defmodule ReqAmazon.SpApi.SupplySources do
  @moduledoc """
  Supply Sources v2020-07-01 operations.
  """

  import ReqAmazon

  @base_path "/supplySources/2020-07-01"

  @spec get_supply_sources(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_supply_sources(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("nextPageToken", Keyword.get(opts, :next_page_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/supplySources", params: params)
  end

  @spec create_supply_source(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_supply_source(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/supplySources", json: payload)
  end

  @spec get_supply_source(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_supply_source(%Req.Request{} = req, supply_source_id)
      when is_binary(supply_source_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/supplySources/#{path_segment(supply_source_id)}"
    )
  end

  @spec update_supply_source(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_supply_source(%Req.Request{} = req, supply_source_id, payload)
      when is_binary(supply_source_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/supplySources/#{path_segment(supply_source_id)}",
      json: payload
    )
  end

  @spec archive_supply_source(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def archive_supply_source(%Req.Request{} = req, supply_source_id)
      when is_binary(supply_source_id) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/supplySources/#{path_segment(supply_source_id)}"
    )
  end

  @spec update_supply_source_status(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_supply_source_status(%Req.Request{} = req, supply_source_id, payload)
      when is_binary(supply_source_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/supplySources/#{path_segment(supply_source_id)}/status",
      json: payload
    )
  end
end
