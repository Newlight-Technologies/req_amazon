defmodule ReqAmazon.SpApi.Uploads do
  @moduledoc """
  Uploads v2020-11-01 operations.

  This companion API is commonly used by A+ Content workflows to create image
  upload destinations before a content document is validated and submitted.
  """

  import ReqAmazon

  @base_path "/uploads/2020-11-01"

  @spec create_upload_destination_for_resource(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_upload_destination_for_resource(%Req.Request{} = req, resource, opts)
      when is_binary(resource) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    content_md5 = Keyword.fetch!(opts, :content_md5)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("contentMD5", content_md5)
      |> put_param("contentType", Keyword.get(opts, :content_type))

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/uploadDestinations/#{path_segment(resource)}",
      params: params
    )
  end
end
