defmodule ReqAmazon.SpApi.Vendor.DirectFulfillment.Inventory do
  @moduledoc """
  Vendor Direct Fulfillment Inventory v1 operations.
  """

  import ReqAmazon

  @spec submit_inventory_update(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_inventory_update(%Req.Request{} = req, warehouse_id, payload)
      when is_binary(warehouse_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "/vendor/directFulfillment/inventory/v1/warehouses/#{path_segment(warehouse_id)}/items",
      json: payload
    )
  end
end
