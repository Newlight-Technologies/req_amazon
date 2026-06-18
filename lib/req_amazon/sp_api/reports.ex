defmodule ReqAmazon.SpApi.Reports do
  @moduledoc """
  Reports v2021-06-30 operations.
  """

  import ReqAmazon
  alias ReqAmazon.SpApi.{Error, Response}

  @base_path "/reports/2021-06-30"

  @spec create_report(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_report(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/reports", json: payload)
  end

  @spec get_report(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_report(%Req.Request{} = req, report_id) when is_binary(report_id) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/reports/#{path_segment(report_id)}")
  end

  @spec cancel_report(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_report(%Req.Request{} = req, report_id) when is_binary(report_id) do
    ReqAmazon.SpApi.request(req, :delete, "#{@base_path}/reports/#{path_segment(report_id)}")
  end

  @spec get_report_document(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_report_document(%Req.Request{} = req, report_document_id, opts \\ [])
      when is_binary(report_document_id) and is_list(opts) do
    params =
      %{}
      |> put_param(
        "enableContentEncodingUrlHeader",
        Keyword.get(opts, :enable_content_encoding_url_header)
      )

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/documents/#{path_segment(report_document_id)}",
      params: params
    )
  end

  @spec stream_report_document(Req.Request.t(), String.t(), term(), keyword()) ::
          {:ok, %{document: map(), response: Req.Response.t()}} | {:error, Error.t()}
  def stream_report_document(%Req.Request{} = req, report_document_id, into, opts \\ [])
      when is_binary(report_document_id) and is_list(opts) do
    document_opts =
      case Keyword.fetch(opts, :enable_content_encoding_url_header) do
        {:ok, value} -> [enable_content_encoding_url_header: value]
        :error -> []
      end

    with {:ok, %Response{body: document}} <-
           get_report_document(req, report_document_id, document_opts),
         {:ok, response} <- download_report_document(document, into, opts) do
      {:ok, %{document: document, response: response}}
    end
  end

  @spec download_report_document(String.t() | map(), term(), keyword()) ::
          {:ok, Req.Response.t()} | {:error, Error.t()}
  def download_report_document(url_or_document, into, opts \\ [])

  def download_report_document(%{"url" => url}, into, opts) do
    download_report_document(url, into, opts)
  end

  def download_report_document(%{url: url}, into, opts) do
    download_report_document(url, into, opts)
  end

  def download_report_document(url, into, opts) when is_binary(url) and is_list(opts) do
    request_opts =
      opts
      |> Keyword.drop([:enable_content_encoding_url_header])
      |> Keyword.merge(method: :get, url: url, into: into)
      |> Keyword.put_new(:raw, true)
      |> Keyword.put_new(:retry, false)

    case Req.request(request_opts) do
      {:ok, %Req.Response{status: status} = response} when status in 200..299 ->
        {:ok, response}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, Error.from_response(status, body)}

      {:error, error} ->
        {:error, Error.wrap(error)}
    end
  end

  def download_report_document(_missing, _into, _opts) do
    {:error,
     Error.from_response(nil, %{
       "errors" => [
         %{
           "code" => "MissingReportDocumentUrl",
           "message" => "Report document metadata did not include a download URL"
         }
       ]
     })}
  end

  @spec list_reports(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_reports(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_csv_param("reportTypes", Keyword.get(opts, :report_types))
      |> put_csv_param("processingStatuses", Keyword.get(opts, :processing_statuses))
      |> put_csv_param("marketplaceIds", Keyword.get(opts, :marketplace_ids))
      |> put_param("createdSince", Keyword.get(opts, :created_since))
      |> put_param("createdUntil", Keyword.get(opts, :created_until))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/reports", params: params)
  end

  @spec create_report_schedule(Req.Request.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_report_schedule(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/schedules", json: payload)
  end

  @spec list_report_schedules(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_report_schedules(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_csv_param("reportTypes", Keyword.get(opts, :report_types))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/schedules", params: params)
  end

  @spec get_report_schedule(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_report_schedule(%Req.Request{} = req, report_schedule_id)
      when is_binary(report_schedule_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/schedules/#{path_segment(report_schedule_id)}"
    )
  end

  @spec cancel_report_schedule(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_report_schedule(%Req.Request{} = req, report_schedule_id)
      when is_binary(report_schedule_id) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/schedules/#{path_segment(report_schedule_id)}"
    )
  end
end
