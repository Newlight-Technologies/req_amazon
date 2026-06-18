defmodule ReqAmazon.SpApi.Services do
  @moduledoc """
  Services v1 operations.
  """

  import ReqAmazon

  @base_path "/service/v1"

  @spec get_service_job_by_service_job_id(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_service_job_by_service_job_id(%Req.Request{} = req, service_job_id)
      when is_binary(service_job_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/serviceJobs/#{path_segment(service_job_id)}"
    )
  end

  @spec cancel_service_job_by_service_job_id(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_service_job_by_service_job_id(%Req.Request{} = req, service_job_id)
      when is_binary(service_job_id) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/serviceJobs/#{path_segment(service_job_id)}/cancellations"
    )
  end

  @spec complete_service_job_by_service_job_id(Req.Request.t(), String.t()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def complete_service_job_by_service_job_id(%Req.Request{} = req, service_job_id)
      when is_binary(service_job_id) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/serviceJobs/#{path_segment(service_job_id)}/completions"
    )
  end

  @spec get_service_jobs(Req.Request.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_service_jobs(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_csv_param("serviceOrderIds", Keyword.get(opts, :service_order_ids))
      |> put_csv_param("serviceJobStatus", Keyword.get(opts, :service_job_status))
      |> put_param("pageToken", Keyword.get(opts, :page_token))
      |> put_param("pageSize", Keyword.get(opts, :page_size))
      |> put_param("sortField", Keyword.get(opts, :sort_field))
      |> put_param("sortOrder", Keyword.get(opts, :sort_order))
      |> put_param("createdAfter", Keyword.get(opts, :created_after))
      |> put_param("createdBefore", Keyword.get(opts, :created_before))
      |> put_param("lastUpdatedAfter", Keyword.get(opts, :last_updated_after))
      |> put_param("lastUpdatedBefore", Keyword.get(opts, :last_updated_before))
      |> put_param("scheduleStartDate", Keyword.get(opts, :schedule_start_date))
      |> put_param("scheduleEndDate", Keyword.get(opts, :schedule_end_date))
      |> put_csv_param("asins", Keyword.get(opts, :asins))
      |> put_csv_param("requiredSkills", Keyword.get(opts, :required_skills))
      |> put_csv_param("storeIds", Keyword.get(opts, :store_ids))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/serviceJobs", params: params)
  end

  @spec add_appointment_for_service_job_by_service_job_id(Req.Request.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def add_appointment_for_service_job_by_service_job_id(
        %Req.Request{} = req,
        service_job_id,
        payload
      )
      when is_binary(service_job_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/serviceJobs/#{path_segment(service_job_id)}/appointments",
      json: payload
    )
  end

  @spec reschedule_appointment_for_service_job_by_service_job_id(
          Req.Request.t(),
          String.t(),
          String.t(),
          map()
        ) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def reschedule_appointment_for_service_job_by_service_job_id(
        %Req.Request{} = req,
        service_job_id,
        appointment_id,
        payload
      )
      when is_binary(service_job_id) and is_binary(appointment_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/serviceJobs/#{path_segment(service_job_id)}/appointments/#{path_segment(appointment_id)}",
      json: payload
    )
  end

  @spec assign_appointment_resources(Req.Request.t(), String.t(), String.t(), map()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def assign_appointment_resources(
        %Req.Request{} = req,
        service_job_id,
        appointment_id,
        payload
      )
      when is_binary(service_job_id) and is_binary(appointment_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :put,
      "#{@base_path}/serviceJobs/#{path_segment(service_job_id)}/appointments/#{path_segment(appointment_id)}/resources",
      json: payload
    )
  end
end
