defmodule ReqAmazon.SpApi.Vehicles do
  @moduledoc """
  Vehicles v2024-11-01 operations.
  """

  import ReqAmazon

  @spec search_vehicles(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_vehicles(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("pageToken", Keyword.get(opts, :page_token))
      |> put_param("pageSize", Keyword.get(opts, :page_size))

    ReqAmazon.SpApi.request(req, :get, "/catalog/2024-11-01/automotive/vehicles", params: params)
  end
end
