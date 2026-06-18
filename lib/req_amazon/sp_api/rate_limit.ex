defmodule ReqAmazon.SpApi.RateLimit do
  @moduledoc """
  Rate-limit-aware retry policy for SP-API requests.

  Installed as the default `:retry` function by `ReqAmazon.SpApi.attach/2`.

  It behaves like Req's `:transient` policy (retrying `408/429/500/502/503/504`
  and transient transport errors, on any method) with one SP-API-specific
  addition: SP-API signals throttling through a per-operation token bucket and
  reports the refill rate in the `x-amzn-RateLimit-Limit` header rather than via
  `Retry-After`. When a `429` carries that rate and no `Retry-After`, this waits
  for roughly one token to refill (`1 / rate` seconds) instead of falling back to
  Req's generic exponential backoff.

  When a `429`/`503` does include `Retry-After`, the policy returns `true` so Req
  honors that header. Override per request by passing your own `:retry`.
  """

  alias ReqAmazon.SpApi.Headers

  # Never sleep longer than this for a single rate-limit wait.
  @max_delay_ms 30_000

  @doc """
  Req `:retry` callback. Returns `{:delay, ms}` for rate-limited 429s, `true`
  for other transient failures (deferring to Req's delay logic), `false`
  otherwise.
  """
  @spec retry(Req.Request.t(), Req.Response.t() | Exception.t()) ::
          {:delay, non_neg_integer()} | boolean()
  def retry(_request, %Req.Response{status: 429} = response) do
    cond do
      # Let Req honor an explicit Retry-After (delta-seconds or HTTP-date).
      Req.Response.get_retry_after(response) -> true
      rate = positive_rate(response) -> {:delay, rate_delay_ms(rate)}
      true -> true
    end
  end

  def retry(_request, response_or_exception), do: transient?(response_or_exception)

  defp positive_rate(response) do
    case Headers.rate_limit(response) do
      rate when is_float(rate) and rate > 0.0 -> rate
      _ -> nil
    end
  end

  defp rate_delay_ms(rate) do
    (1000 / rate)
    |> Float.ceil()
    |> trunc()
    |> min(@max_delay_ms)
  end

  # Mirror of Req's own `:transient` predicate.
  defp transient?(%Req.Response{status: status}) when status in [408, 429, 500, 502, 503, 504],
    do: true

  defp transient?(%Req.Response{}), do: false

  defp transient?(%Req.TransportError{reason: reason})
       when reason in [:timeout, :econnrefused, :closed],
       do: true

  defp transient?(%Req.HTTPError{protocol: :http2, reason: reason})
       when reason in [:unprocessed, :pool_not_available],
       do: true

  defp transient?(%{__exception__: true}), do: false
end
