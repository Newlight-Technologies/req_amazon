defmodule ReqAmazon do
  @moduledoc """
  Shared utilities for Amazon API Req plugins.

  This module provides common helpers used across all Amazon API plugins
  in this library. For the SP-API Req plugin, see
  `ReqAmazon.SpApi`.
  """

  @type params_map :: %{optional(String.t()) => term()}

  @doc false
  @spec path_segment(term()) :: String.t()
  def path_segment(value) do
    value
    |> to_string()
    |> URI.encode(&unreserved_char?/1)
  end

  @doc false
  @spec put_param(params_map(), String.t(), term() | nil) :: params_map()
  def put_param(params, _name, nil), do: params

  def put_param(params, name, value) do
    Map.put(params, name, value)
  end

  @doc false
  @spec put_csv_param(params_map(), String.t(), [term()] | nil) :: params_map()
  def put_csv_param(params, _name, nil), do: params
  def put_csv_param(params, _name, []), do: params

  def put_csv_param(params, name, values) do
    Map.put(params, name, csv(values))
  end

  @doc false
  @spec csv([term()]) :: String.t()
  def csv(values) when is_list(values) do
    Enum.map_join(values, ",", &to_string/1)
  end

  @doc false
  @spec unwrap_payload(term()) :: term()
  def unwrap_payload(%{"payload" => payload}), do: payload
  def unwrap_payload(body), do: body

  defp unreserved_char?(char) when char in ?a..?z, do: true
  defp unreserved_char?(char) when char in ?A..?Z, do: true
  defp unreserved_char?(char) when char in ?0..?9, do: true
  defp unreserved_char?(char) when char in [?-, ?_, ?., ?~], do: true
  defp unreserved_char?(_char), do: false
end
