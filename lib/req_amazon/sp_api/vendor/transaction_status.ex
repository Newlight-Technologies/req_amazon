defmodule ReqAmazon.SpApi.Vendor.TransactionStatus do
  @moduledoc """
  Vendor Transaction Status v1 operations.
  """

  import ReqAmazon

  @spec get_transaction(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_transaction(%Req.Request{} = req, transaction_id) when is_binary(transaction_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "/vendor/transactions/v1/transactions/#{path_segment(transaction_id)}"
    )
  end
end
