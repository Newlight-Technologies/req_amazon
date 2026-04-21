defmodule ReqAmazon.SpApi.Finances do
  @moduledoc """
  Finances v0 operations.
  """

  import ReqAmazon

  @base_path "/finances/v0"

  @spec list_financial_event_groups(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_financial_event_groups(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_param(
        "FinancialEventGroupStartedAfter",
        Keyword.get(opts, :financial_event_group_started_after)
      )
      |> put_param(
        "FinancialEventGroupStartedBefore",
        Keyword.get(opts, :financial_event_group_started_before)
      )
      |> put_param("NextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/financialEventGroups", params: params)
  end

  @spec list_financial_events_by_group_id(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_financial_events_by_group_id(%Req.Request{} = req, event_group_id, opts \\ [])
      when is_binary(event_group_id) and is_list(opts) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/financialEventGroups/#{path_segment(event_group_id)}/financialEvents",
      params: posted_date_params(opts)
    )
  end

  @spec list_financial_events_by_order_id(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_financial_events_by_order_id(%Req.Request{} = req, order_id, opts \\ [])
      when is_binary(order_id) and is_list(opts) do
    params =
      %{}
      |> put_param("NextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(order_id)}/financialEvents",
      params: params
    )
  end

  @spec list_financial_events(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_financial_events(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/financialEvents",
      params: posted_date_params(opts)
    )
  end

  defp posted_date_params(opts) do
    %{}
    |> put_param("PostedAfter", Keyword.get(opts, :posted_after))
    |> put_param("PostedBefore", Keyword.get(opts, :posted_before))
    |> put_param("NextToken", Keyword.get(opts, :next_token))
  end
end
