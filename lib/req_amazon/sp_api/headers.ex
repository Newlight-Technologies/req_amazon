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

  @spec retry_after(Req.Response.t()) :: non_neg_integer() | nil
  def retry_after(%Req.Response{} = response) do
    parse_integer(first(response, "retry-after"))
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

  defp parse_integer(nil), do: nil

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {seconds, ""} when seconds >= 0 -> seconds
      _invalid -> nil
    end
  end
end
