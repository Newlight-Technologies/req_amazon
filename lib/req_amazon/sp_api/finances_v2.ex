defmodule ReqAmazon.SpApi.FinancesV2 do
  @moduledoc """
  Finances v2024-06-19 (Transactions API) operations.
  """

  import ReqAmazon

  @base_path "/finances/2024-06-19"

  @spec list_transactions(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_transactions(%Req.Request{} = req, opts) when is_list(opts) do
    posted_after = Keyword.fetch!(opts, :posted_after)
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)

    params =
      %{}
      |> put_param("postedAfter", posted_after)
      |> put_param("postedBefore", Keyword.get(opts, :posted_before))
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/transactions", params: params)
  end
end
