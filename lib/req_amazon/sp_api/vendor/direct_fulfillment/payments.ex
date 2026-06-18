defmodule ReqAmazon.SpApi.Vendor.DirectFulfillment.Payments do
  @moduledoc """
  Vendor Direct Fulfillment Payments v1 operations.
  """

  @spec submit_invoices(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_invoices(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "/vendor/directFulfillment/payments/v1/invoices",
      json: payload
    )
  end
end
