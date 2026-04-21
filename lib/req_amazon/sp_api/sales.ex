defmodule ReqAmazon.SpApi.Sales do
  @moduledoc """
  Sales v1 operations.
  """

  import ReqAmazon

  @spec get_order_metrics(Req.Request.t(), keyword()) ::
          {:ok, map()} | {:error, ReqAmazon.SpApi.Error.t()}
  def get_order_metrics(%Req.Request{} = req, opts) when is_list(opts) do
    marketplace_ids = Keyword.fetch!(opts, :marketplace_ids)
    interval = Keyword.fetch!(opts, :interval)
    granularity = Keyword.fetch!(opts, :granularity)

    params =
      %{}
      |> put_csv_param("marketplaceIds", marketplace_ids)
      |> put_param("interval", interval)
      |> put_param("granularity", granularity)
      |> put_param("granularityTimeZone", Keyword.get(opts, :granularity_time_zone))
      |> put_param("buyerType", Keyword.get(opts, :buyer_type))
      |> put_param("fulfillmentNetwork", Keyword.get(opts, :fulfillment_network))
      |> put_param("firstDayOfWeek", Keyword.get(opts, :first_day_of_week))
      |> put_csv_param("asin", Keyword.get(opts, :asin))
      |> put_param("sku", Keyword.get(opts, :sku))

    ReqAmazon.SpApi.request(req, :get, "/sales/v1/orderMetrics", params: params)
  end
end
