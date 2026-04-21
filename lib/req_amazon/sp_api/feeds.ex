defmodule ReqAmazon.SpApi.Feeds do
  @moduledoc """
  Feeds v2021-06-30 operations.
  """

  import ReqAmazon

  @base_path "/feeds/2021-06-30"

  @spec create_feed_document(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_feed_document(%Req.Request{} = req, content_type) when is_binary(content_type) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/documents",
      json: %{"contentType" => content_type}
    )
  end

  @spec create_feed(Req.Request.t(), map()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_feed(%Req.Request{} = req, payload) when is_map(payload) do
    ReqAmazon.SpApi.request(req, :post, "#{@base_path}/feeds", json: payload)
  end

  @spec get_feed(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_feed(%Req.Request{} = req, feed_id) when is_binary(feed_id) do
    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/feeds/#{path_segment(feed_id)}")
  end

  @spec get_feed_document(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_feed_document(%Req.Request{} = req, feed_document_id)
      when is_binary(feed_document_id) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/documents/#{path_segment(feed_document_id)}"
    )
  end

  @spec cancel_feed(Req.Request.t(), String.t()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def cancel_feed(%Req.Request{} = req, feed_id) when is_binary(feed_id) do
    ReqAmazon.SpApi.request(req, :delete, "#{@base_path}/feeds/#{path_segment(feed_id)}")
  end

  @spec list_feeds(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def list_feeds(%Req.Request{} = req, opts \\ []) when is_list(opts) do
    params =
      %{}
      |> put_csv_param("feedTypes", Keyword.get(opts, :feed_types))
      |> put_csv_param("marketplaceIds", Keyword.get(opts, :marketplace_ids))
      |> put_csv_param("processingStatuses", Keyword.get(opts, :processing_statuses))
      |> put_param("createdSince", Keyword.get(opts, :created_since))
      |> put_param("createdUntil", Keyword.get(opts, :created_until))
      |> put_param("nextToken", Keyword.get(opts, :next_token))

    ReqAmazon.SpApi.request(req, :get, "#{@base_path}/feeds", params: params)
  end
end
