defmodule ReqAmazon.SpApi.Transfers do
  @moduledoc """
  Transfers v2024-06-01 operations.
  """

  @base_path "/finances/transfers/2024-06-01"

  @spec get_payment_methods(Req.Request.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_payment_methods(%Req.Request{} = req) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/paymentMethods")
  end

  @spec initiate_payout(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def initiate_payout(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/payouts", json: payload)
  end
end
