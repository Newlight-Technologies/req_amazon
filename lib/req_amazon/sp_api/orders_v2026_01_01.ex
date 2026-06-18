defmodule ReqAmazon.SpApi.OrdersV20260101 do
  @moduledoc """
  Orders v2026-01-01 operations.

  This current Orders wrapper lives alongside the legacy
  `ReqAmazon.SpApi.Orders` v0 module.

  Amazon's v2026-01-01 Orders API exposes `searchOrders` and `getOrder`.
  Compatibility helpers that mirror common v0 read paths delegate to
  `get_order/3` with the appropriate `included_data` values.
  Shipment confirmation remains available only in the legacy v0 module.
  """

  import ReqAmazon

  @base_path "/orders/2026-01-01"

  @spec search_orders(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_orders(%Req.Request{} = req, opts) when is_list(opts) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/orders", params: search_params(opts))
  end

  @spec list_orders(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_orders(%Req.Request{} = req, opts) when is_list(opts) do
    search_orders(req, opts)
  end

  @spec get_order(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    params =
      %{}
      |> put_csv_param("includedData", Keyword.get(opts, :included_data))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}",
      params: params
    )
  end

  @spec get_order_items(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_items(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    get_order(req, order_id, opts)
  end

  @spec get_order_buyer_info(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_buyer_info(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    get_order(req, order_id, with_included_data(opts, ["BUYER"]))
  end

  @spec get_order_address(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_address(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    get_order(req, order_id, with_included_data(opts, ["RECIPIENT"]))
  end

  @spec get_order_items_buyer_info(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_items_buyer_info(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    get_order(req, order_id, with_included_data(opts, ["BUYER"]))
  end

  defp search_params(opts) do
    %{}
    |> put_param("createdAfter", Keyword.get(opts, :created_after))
    |> put_param("createdBefore", Keyword.get(opts, :created_before))
    |> put_param("lastUpdatedAfter", Keyword.get(opts, :last_updated_after))
    |> put_param("lastUpdatedBefore", Keyword.get(opts, :last_updated_before))
    |> put_csv_param("fulfillmentStatuses", Keyword.get(opts, :fulfillment_statuses))
    |> put_csv_param("marketplaceIds", Keyword.get(opts, :marketplace_ids))
    |> put_csv_param("fulfilledBy", Keyword.get(opts, :fulfilled_by))
    |> put_param("maxResultsPerPage", Keyword.get(opts, :max_results_per_page))
    |> put_param("paginationToken", Keyword.get(opts, :pagination_token))
    |> put_csv_param("includedData", Keyword.get(opts, :included_data))
  end

  defp with_included_data(opts, included_data) do
    existing_included_data = Keyword.get(opts, :included_data, [])

    Keyword.put(
      opts,
      :included_data,
      Enum.uniq(List.wrap(existing_included_data) ++ List.wrap(included_data))
    )
  end
end
