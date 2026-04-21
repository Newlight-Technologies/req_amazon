defmodule ReqAmazon.SpApi.ApplicationManagement do
  @moduledoc """
  Application Management v2023-11-30 operations.
  """

  @spec rotate_application_client_secret(Req.Request.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def rotate_application_client_secret(%Req.Request{} = req) do
    ReqAmazon.SpApi.request(req, :post, "/applications/2023-11-30/clientSecret")
  end
end
