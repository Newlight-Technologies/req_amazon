defmodule ReqAmazon.SpApi.AppIntegrations do
  @moduledoc """
  App Integrations v2024-04-01 operations.
  """

  import ReqAmazon

  @base_path "/appIntegrations/2024-04-01"

  @spec create_notification(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_notification(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/notifications", json: payload)
  end

  @spec delete_notifications(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def delete_notifications(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/notifications/deletion", json: payload)
  end

  @spec record_action_feedback(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def record_action_feedback(%Req.Request{} = req, notification_id, payload)
      when is_binary(notification_id) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/notifications/#{path_segment(notification_id)}/feedback",
      json: payload
    )
  end
end
