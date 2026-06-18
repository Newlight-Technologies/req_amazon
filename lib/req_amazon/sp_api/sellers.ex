defmodule ReqAmazon.SpApi.Sellers do
  @moduledoc """
  Sellers v1 operations.

  `get_account/1` is documented by Amazon as an EU-only operation.
  """

  @spec get_marketplace_participations(Req.Request.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_marketplace_participations(%Req.Request{} = req) do
    ReqAmazon.SpApi.request(req, :get, "/sellers/v1/marketplaceParticipations")
  end

  @spec get_account(Req.Request.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_account(%Req.Request{} = req) do
    ReqAmazon.SpApi.request(req, :get, "/sellers/v1/account")
  end
end
