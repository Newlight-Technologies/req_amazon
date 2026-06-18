defmodule ReqAmazon.SpApi.DataKiosk do
  @moduledoc """
  Data Kiosk v2023-11-15 operations.
  """

  import ReqAmazon

  @base_path "/dataKiosk/2023-11-15"

  @spec get_queries(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_queries(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_csv_param("processingStatuses", Keyword.get(opts, :processing_statuses))
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("createdSince", Keyword.get(opts, :created_since))
      |> put_param("createdUntil", Keyword.get(opts, :created_until))
      |> put_param("paginationToken", Keyword.get(opts, :pagination_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/queries", params: params)
  end

  @spec create_query(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_query(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/queries", json: payload)
  end

  @spec get_query(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_query(%Req.Request{} = req, query_id) when is_binary(query_id) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/queries/#{path_segment(query_id)}")
  end

  @spec cancel_query(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_query(%Req.Request{} = req, query_id) when is_binary(query_id) do
    ReqAmazon.SpApi.request(req, :delete, "#{@base_path}/queries/#{path_segment(query_id)}")
  end

  @spec get_document(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_document(%Req.Request{} = req, document_id) when is_binary(document_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/documents/#{path_segment(document_id)}"
    )
  end
end
