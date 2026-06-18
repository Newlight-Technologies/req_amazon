defmodule ReqAmazon.SpApi.CustomerFeedback do
  @moduledoc """
  Customer Feedback v2024-06-01 operations.
  """

  import ReqAmazon

  @base_path "/customerFeedback/2024-06-01"

  @spec get_item_review_topics(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_review_topics(%Req.Request{} = req, asin, opts)
      when is_binary(asin) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(asin)}/reviews/topics",
      params: params
    )
  end

  @spec get_item_browse_node(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_browse_node(%Req.Request{} = req, asin, opts)
      when is_binary(asin) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(asin)}/browseNode",
      params: params
    )
  end

  @spec get_browse_node_review_topics(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_browse_node_review_topics(%Req.Request{} = req, browse_node_id, opts)
      when is_binary(browse_node_id) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/browseNodes/#{path_segment(browse_node_id)}/reviews/topics",
      params: params
    )
  end

  @spec get_item_review_trends(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_item_review_trends(%Req.Request{} = req, asin, opts)
      when is_binary(asin) and is_list(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    params = %{} |> put_param("marketplaceId", marketplace_id)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/items/#{path_segment(asin)}/reviews/trends",
      params: params
    )
  end

  @spec get_browse_node_review_trends(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_browse_node_review_trends(%Req.Request{} = req, browse_node_id, opts)
      when is_binary(browse_node_id) and is_list(opts) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/browseNodes/#{path_segment(browse_node_id)}/reviews/trends",
      params: marketplace_params(opts)
    )
  end

  @spec get_browse_node_return_topics(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_browse_node_return_topics(%Req.Request{} = req, browse_node_id, opts)
      when is_binary(browse_node_id) and is_list(opts) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/browseNodes/#{path_segment(browse_node_id)}/returns/topics",
      params: marketplace_params(opts)
    )
  end

  @spec get_browse_node_return_trends(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_browse_node_return_trends(%Req.Request{} = req, browse_node_id, opts)
      when is_binary(browse_node_id) and is_list(opts) do
    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/browseNodes/#{path_segment(browse_node_id)}/returns/trends",
      params: marketplace_params(opts)
    )
  end

  defp marketplace_params(opts) do
    marketplace_id = Keyword.fetch!(opts, :marketplace_id)
    %{} |> put_param("marketplaceId", marketplace_id)
  end
end
