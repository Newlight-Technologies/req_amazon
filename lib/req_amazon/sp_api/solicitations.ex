defmodule ReqAmazon.SpApi.Solicitations do
  @moduledoc """
  Solicitations v1 operations.
  """

  import ReqAmazon

  @base_path "/solicitations/v1"

  @spec get_solicitation_actions_for_order(Req.Request.t(), String.t(), keyword()) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_solicitation_actions_for_order(%Req.Request{} = req, amazon_order_id, opts)
      when is_binary(amazon_order_id) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :get,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}",
      params: params
    )
  end

  @spec create_product_review_and_seller_feedback_solicitation(
          Req.Request.t(),
          String.t(),
          keyword()
        ) ::
          {:ok, ReqAmazon.SpApi.Response.t()} | {:error, ReqAmazon.SpApi.Error.t()}
  def create_product_review_and_seller_feedback_solicitation(
        %Req.Request{} = req,
        amazon_order_id,
        opts
      )
      when is_binary(amazon_order_id) and is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    params = %{} |> put_csv_param("marketplaceIds", marketplace_ids)

    ReqAmazon.SpApi.request(
      req,
      :post,
      "#{@base_path}/orders/#{path_segment(amazon_order_id)}/solicitations/productReviewAndSellerFeedback",
      params: params
    )
  end
end
