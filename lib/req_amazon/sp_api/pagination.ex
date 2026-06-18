defmodule ReqAmazon.SpApi.Pagination do
  @moduledoc """
  Pagination helpers for SP-API responses.

  Amazon is inconsistent about where the continuation token lives and how it is
  cased. Orders and Finances (v0) return `NextToken` at the top of the payload,
  Reports returns a top-level `nextToken`, and the newer APIs nest it under a
  `pagination` object — which, for FBA Inventory, sits *beside* `payload` rather
  than inside it.

  `next_token/1` runs against the original response envelope (before the
  `payload` wrapper is stripped) so it finds the token regardless of shape.
  """

  # Checked in order. The `pagination` object wins over a bare token because
  # FBA Inventory carries both `payload` and a sibling `pagination`.
  # `paginationToken` is the request-side parameter name on the newer APIs
  # (Data Kiosk, Fulfillment Inbound v2024, Orders v2026); their responses use
  # `pagination.nextToken`, but we accept `pagination.paginationToken` as a
  # defensive fallback so a symmetric response shape still paginates.
  @token_paths [
    ["pagination", "nextToken"],
    ["pagination", "paginationToken"],
    ["Pagination", "NextToken"],
    ["nextToken"],
    ["NextToken"],
    ["payload", "pagination", "nextToken"],
    ["payload", "nextToken"],
    ["payload", "NextToken"]
  ]

  @doc """
  Extracts and normalizes the continuation token from a raw response envelope.

  Returns the token string, or `nil` when there is no next page.
  """
  @spec next_token(term()) :: String.t() | nil
  def next_token(body) when is_map(body), do: find_token(body, @token_paths)
  def next_token(_body), do: nil

  defp find_token(_body, []), do: nil

  defp find_token(body, [path | rest]) do
    case dig(body, path) do
      token when is_binary(token) and token != "" -> token
      _ -> find_token(body, rest)
    end
  end

  defp dig(body, path) do
    Enum.reduce_while(path, body, fn
      key, %{} = acc -> {:cont, Map.get(acc, key)}
      _key, _acc -> {:halt, nil}
    end)
  end
end
