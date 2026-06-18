defmodule ReqAmazon.SpApi.FinancesV20240619 do
  @moduledoc """
  Finances v2024-06-19 (Transactions API) operations.
  """

  import ReqAmazon

  @base_path "/finances/2024-06-19"

  @spec list_transactions(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_transactions(%Req.Request{} = req, opts) when is_list(opts) do
    posted_after = Keyword.fetch!(opts, :posted_after)

    params =
      %{}
      |> put_param("postedAfter", posted_after)
      |> put_param("postedBefore", Keyword.get(opts, :posted_before))
      |> put_param("marketplaceId", Keyword.get(opts, :marketplace_id))
      |> put_param("transactionStatus", Keyword.get(opts, :transaction_status))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/transactions", params: params)
  end
end
