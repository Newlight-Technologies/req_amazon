defmodule ReqAmazon.SpApi.Vendor.DirectFulfillment.TransactionStatus do
  @moduledoc """
  Vendor Direct Fulfillment Transaction Status v2021-12-28 operations.
  """

  import ReqAmazon

  @spec get_transaction_status(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_transaction_status(%Req.Request{} = req, transaction_id)
      when is_binary(transaction_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "/vendor/directFulfillment/transactions/2021-12-28/transactions/#{path_segment(transaction_id)}"
    )
  end
end
