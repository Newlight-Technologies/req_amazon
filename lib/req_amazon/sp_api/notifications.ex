defmodule ReqAmazon.SpApi.Notifications do
  @moduledoc """
  Notifications v1 operations.

  This API family includes grantless operations in Amazon's authorization model.
  When your application handles token acquisition itself, use caller-managed
  `:access_token` support in `ReqAmazon.SpApi.attach/2` or
  `ReqAmazon.SpApi.Client.new/1` and supply the grantless token for the request.
  """

  import ReqAmazon

  @base_path "/notifications/v1"

  @spec get_subscription(Req.Request.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_subscription(%Req.Request{} = req, notification_type, opts \\ [])
      when is_binary(notification_type) and is_list(opts) do
    params =
      %{}
      |> put_param("payloadVersion", Keyword.get(opts, :payload_version))

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/subscriptions/#{path_segment(notification_type)}",
      params: params
    )
  end

  @spec create_subscription(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_subscription(%Req.Request{} = req, notification_type, payload)
      when is_binary(notification_type) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/subscriptions/#{path_segment(notification_type)}",
      json: payload
    )
  end

  @spec send_test_notification(Req.Request.t(), String.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def send_test_notification(%Req.Request{} = req, notification_type, payload)
      when is_binary(notification_type) and is_map(payload) do
    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/subscriptions/#{path_segment(notification_type)}/testNotification",
      json: payload
    )
  end

  @spec get_subscription_by_id(Req.Request.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_subscription_by_id(%Req.Request{} = req, notification_type, subscription_id)
      when is_binary(notification_type) and is_binary(subscription_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/subscriptions/#{path_segment(notification_type)}/#{path_segment(subscription_id)}"
    )
  end

  @spec delete_subscription_by_id(Req.Request.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def delete_subscription_by_id(%Req.Request{} = req, notification_type, subscription_id)
      when is_binary(notification_type) and is_binary(subscription_id) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/subscriptions/#{path_segment(notification_type)}/#{path_segment(subscription_id)}"
    )
  end

  @spec get_destinations(Req.Request.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_destinations(%Req.Request{} = req) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/destinations")
  end

  @spec create_destination(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_destination(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/destinations", json: payload)
  end

  @spec get_destination(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_destination(%Req.Request{} = req, destination_id) when is_binary(destination_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/destinations/#{path_segment(destination_id)}"
    )
  end

  @spec delete_destination(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def delete_destination(%Req.Request{} = req, destination_id) when is_binary(destination_id) do
    ReqAmazon.SpApi.request(
      req,
      :delete,
      "#{@base_path}/destinations/#{path_segment(destination_id)}"
    )
  end
end
