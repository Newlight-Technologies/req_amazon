defmodule ReqAmazon.SpApi.APlusContent do
  @moduledoc """
  A+ Content v2020-11-01 operations.
  """

  import ReqAmazon

  @base_path "/aplus/2020-11-01"

  @spec search_content_documents(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_content_documents(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)

    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("pageToken", Keyword.get(opts, :page_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/contentDocuments", params: params)
  end

  @spec create_content_document(Req.Request.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_content_document(%Req.Request{} = req, opts, payload)
      when is_list(opts) and is_map(payload) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/contentDocuments",
      params: params,
      json: payload
    )
  end

  @spec get_content_document(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_content_document(%Req.Request{} = req, content_reference_key, opts)
      when is_binary(content_reference_key) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)

    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_csv_param("includedDataSet", Keyword.get(opts, :included_data_set))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/contentDocuments/#{path_segment(content_reference_key)}",
      params: params
    )
  end

  @spec update_content_document(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def update_content_document(%Req.Request{} = req, content_reference_key, opts, payload)
      when is_binary(content_reference_key) and is_list(opts) and is_map(payload) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/contentDocuments/#{path_segment(content_reference_key)}",
      params: params,
      json: payload
    )
  end

  @spec list_content_document_asin_relations(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_content_document_asin_relations(%Req.Request{} = req, content_reference_key, opts)
      when is_binary(content_reference_key) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)

    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("pageToken", Keyword.get(opts, :page_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/contentDocuments/#{path_segment(content_reference_key)}/asins",
      params: params
    )
  end

  @spec post_content_document_asin_relations(Req.Request.t(), String.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def post_content_document_asin_relations(
        %Req.Request{} = req,
        content_reference_key,
        opts,
        payload
      )
      when is_binary(content_reference_key) and is_list(opts) and is_map(payload) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/contentDocuments/#{path_segment(content_reference_key)}/asins",
      params: params,
      json: payload
    )
  end

  @spec validate_content_document_asin_relations(Req.Request.t(), keyword(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def validate_content_document_asin_relations(%Req.Request{} = req, opts, payload)
      when is_list(opts) and is_map(payload) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/contentAsinValidations",
      params: params,
      json: payload
    )
  end

  @spec search_content_publish_records(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def search_content_publish_records(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    asin = Keyword.fetch!(opts, :asin)

    params =
      %{}
      |> put_param("marketplaceId", marketplace_id)
      |> put_param("asin", asin)
      |> put_param("pageToken", Keyword.get(opts, :page_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/contentPublishRecords", params: params)
  end

  @spec post_content_document_approval_submission(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def post_content_document_approval_submission(
        %Req.Request{} = req,
        content_reference_key,
        opts
      )
      when is_binary(content_reference_key) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/contentDocuments/#{path_segment(content_reference_key)}/approvalSubmissions",
      params: params
    )
  end

  @spec post_content_document_suspend_submission(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def post_content_document_suspend_submission(
        %Req.Request{} = req,
        content_reference_key,
        opts
      )
      when is_binary(content_reference_key) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/contentDocuments/#{path_segment(content_reference_key)}/suspendSubmissions",
      params: params
    )
  end
end
