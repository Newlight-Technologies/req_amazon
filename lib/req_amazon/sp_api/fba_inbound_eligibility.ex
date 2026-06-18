defmodule ReqAmazon.SpApi.FbaInboundEligibility do
  @moduledoc """
  FBA Inbound Eligibility v1 operations.
  """

  import ReqAmazon

  @spec get_item_eligibility_preview(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_eligibility_preview(%Req.Request{} = req, opts) when is_list(opts) do
    asin = Keyword.fetch!(opts, :asin)
    program = Keyword.fetch!(opts, :program)

    params =
      %{}
      |> put_param("asin", asin)
      |> put_param("program", program)
      |> put_csv_param("marketplaceIds", Keyword.get(opts, :marketplace_ids))

    ReqAmazon.SpApi.request(req, :get, "/fba/inbound/v1/eligibility/itemPreview", params: params)
  end
end
