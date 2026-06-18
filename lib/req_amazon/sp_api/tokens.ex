defmodule ReqAmazon.SpApi.Tokens do
  @moduledoc """
  Tokens v2021-03-01 operations.
  """

  @base_path "/tokens/2021-03-01"

  @spec create_restricted_data_token(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_restricted_data_token(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/restrictedDataToken", json: payload)
  end
end
