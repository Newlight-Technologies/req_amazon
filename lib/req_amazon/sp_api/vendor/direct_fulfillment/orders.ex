defmodule ReqAmazon.SpApi.Vendor.DirectFulfillment.Orders do
  @moduledoc """
  Vendor Direct Fulfillment Orders v2021-12-28 operations.
  """

  import ReqAmazon

  @base_path "/vendor/directFulfillment/orders/2021-12-28"

  @spec get_orders(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_orders(%Req.Request{} = req, opts) when is_list(opts) do
    created_after = Keyword.fetch!(opts, :created_after)
    created_before = Keyword.fetch!(opts, :created_before)

    params =
      %{}
      |> put_param("createdAfter", created_after)
      |> put_param("createdBefore", created_before)
      |> put_param("shipFromPartyId", Keyword.get(opts, :ship_from_party_id))
      |> put_param("status", Keyword.get(opts, :status))
      |> put_param("limit", Keyword.get(opts, :limit))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_param("includeDetails", Keyword.get(opts, :include_details))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/purchaseOrders", params: params)
  end

  @spec get_order(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order(%Req.Request{} = req, purchase_order_number)
      when is_binary(purchase_order_number) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/purchaseOrders/#{path_segment(purchase_order_number)}"
    )
  end

  @spec submit_acknowledgement(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_acknowledgement(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/acknowledgements", json: payload)
  end
end
