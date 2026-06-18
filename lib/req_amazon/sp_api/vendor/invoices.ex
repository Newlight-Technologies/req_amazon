defmodule ReqAmazon.SpApi.Vendor.Invoices do
  @moduledoc """
  Vendor Invoices (Retail Procurement) v1 operations.
  """

  @spec submit_invoices(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def submit_invoices(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "/vendor/payments/v1/invoices", json: payload)
  end
end
