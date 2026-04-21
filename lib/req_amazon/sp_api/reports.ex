defmodule ReqAmazon.SpApi.Reports do
  @moduledoc """
  Reports v2021-06-30 operations.
  """

  import ReqAmazon

  @base_path "/reports/2021-06-30"

  @spec create_report(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_report(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/reports", json: payload)
  end

  @spec get_report(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_report(%Req.Request{} = req, report_id) when is_binary(report_id) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/reports/#{path_segment(report_id)}")
  end

  @spec cancel_report(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_report(%Req.Request{} = req, report_id) when is_binary(report_id) do
    ReqAmazon.SpApi.request(req, :delete, "#{@base_path}/reports/#{path_segment(report_id)}")
  end

  @spec get_report_document(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_report_document(%Req.Request{} = req, report_document_id)
      when is_binary(report_document_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/documents/#{path_segment(report_document_id)}"
    )
  end

  @spec list_reports(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
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
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_report_schedule(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/schedules", json: payload)
  end

  @spec list_report_schedules(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_report_schedules(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_csv_param("reportTypes", Keyword.get(opts, :report_types))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/schedules", params: params)
  end

  @spec get_report_schedule(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_report_schedule(%Req.Request{} = req, report_schedule_id)
      when is_binary(report_schedule_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/schedules/#{path_segment(report_schedule_id)}"
    )
  end

  @spec cancel_report_schedule(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_report_schedule(%Req.Request{} = req, report_schedule_id)
      when is_binary(report_schedule_id) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/schedules/#{path_segment(report_schedule_id)}"
    )
  end
end
