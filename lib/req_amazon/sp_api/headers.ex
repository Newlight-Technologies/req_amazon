defmodule ReqAmazon.SpApi.Headers do
  @moduledoc false

  # Extracts the SP-API observability/throttling metadata that Amazon returns on
  # every response but that callers otherwise have to dig out of raw headers.
  #
  # Header names are matched case-insensitively via `Req.Response.get_header/2`,
  # which downcases header keys.

  @spec request_id(Req.Response.t()) :: String.t() | nil
  def request_id(%Req.Response{} = response) do
    first(response, "x-amzn-requestid") || first(response, "x-amzn-request-id")
  end

  @spec rate_limit(Req.Response.t()) :: float() | nil
  def rate_limit(%Req.Response{} = response) do
    parse_float(first(response, "x-amzn-ratelimit-limit"))
  end

  # Note: SP-API throttles by rate (`x-amzn-RateLimit-Limit`), not `Retry-After`,
  # so this is mostly defensive against fronting gateways/WAFs that emit a
  # standard 429. RFC 7231 allows either delta-seconds or an HTTP-date; both are
  # normalized to "seconds from now" (never negative).
  @spec retry_after(Req.Response.t()) :: non_neg_integer() | nil
  def retry_after(%Req.Response{} = response) do
    parse_retry_after(first(response, "retry-after"))
  end

  defp first(response, name) do
    response
    |> Req.Response.get_header(name)
    |> List.first()
  end

  defp parse_float(nil), do: nil

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {rate, ""} -> rate
      _invalid -> nil
    end
  end

  # Delta-seconds only. RFC 7231 also permits an HTTP-date, but SP-API does not
  # send `Retry-After` at all (it throttles by rate; see `rate_limit/1`), and the
  # gateways that do emit it use delta-seconds. An HTTP-date is parsed as `nil`
  # rather than pulling in OTP `inets` for a form Amazon never returns.
  defp parse_retry_after(nil), do: nil

  defp parse_retry_after(value) when is_binary(value) do
    case Integer.parse(value) do
      {seconds, ""} when seconds >= 0 -> seconds
      _invalid -> nil
    end
  end
end
