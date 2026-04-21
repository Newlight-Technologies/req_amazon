defmodule ReqAmazon.SpApi.ExternalFulfillment do
  @moduledoc """
  External Fulfillment v2024-09-11 operations (shipping, inventory, and returns).
  """

  import ReqAmazon

  @base_path "/externalFulfillment"

  # --- Shipping ---

  @spec get_shipments(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_shipments(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("maxResults", Keyword.get(opts, :max_results))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/2024-09-11/shipments", params: params)
  end

  # --- Inventory ---

  @spec submit_inventory_update(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_inventory_update(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/inventory/2024-09-11/inventories",
      json: payload
    )
  end

  # --- Returns ---

  @spec list_returns(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_returns(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("maxResults", Keyword.get(opts, :max_results))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/2024-09-11/returns", params: params)
  end

  @spec get_return(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_return(%Req.Request{} = req, return_id) when is_binary(return_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/2024-09-11/returns/#{path_segment(return_id)}"
    )
  end
end
