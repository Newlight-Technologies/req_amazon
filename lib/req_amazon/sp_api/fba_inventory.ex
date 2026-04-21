defmodule ReqAmazon.SpApi.FbaInventory do
  @moduledoc """
  FBA Inventory v1 operations.
  """

  import ReqAmazon

  @spec get_inventory_summaries(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_inventory_summaries(%Req.Request{} = req, marketplace_id, opts \\ [])
      when is_binary(marketplace_id) and is_list(opts) do
    params =
      %{}
      |> put_param("details", Keyword.get(opts, :details))
      |> put_param("granularityType", "Marketplace")
      |> put_param("granularityId", marketplace_id)
      |> put_csv_param("sellerSkus", Keyword.get(opts, :skus))
      |> put_param("nextToken", Keyword.get(opts, :next_token))
      |> put_csv_param("marketplaceIds", [marketplace_id])

    ReqAmazon.SpApi.request(req, :get, "/fba/inventory/v1/summaries", params: params)
  end
end
