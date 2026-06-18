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

  `stream/1` follows that token to lazily page through an operation.
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

  @doc """
  Lazily pages through an operation, following `next_token`.

  `fun` receives the continuation token (`nil` on the first call) and must return
  an operation result. Because `put_param/3` drops `nil`, passing the token
  straight through omits it on the first request:

      ReqAmazon.SpApi.Pagination.stream(fn token ->
        ReqAmazon.SpApi.Orders.list_orders(req, Keyword.put(opts, :next_token, token))
      end)
      |> Stream.flat_map(& &1.body["Orders"])
      |> Enum.to_list()

  The stream yields one `ReqAmazon.SpApi.Response` per page and stops after the
  page whose `next_token` is `nil`. An error **raises** the
  `ReqAmazon.SpApi.Error` (a paginated sequence can't meaningfully continue past
  a failed page); wrap enumeration in `try/1` if you need to recover.
  """
  @spec stream((String.t() | nil -> {:ok, map()} | {:error, Exception.t()})) :: Enumerable.t()
  def stream(fun) when is_function(fun, 1) do
    # Matched as a plain map (not %Response{}) so this module stays independent of
    # ReqAmazon.SpApi.Response, which depends on `next_token/1` here.
    Stream.resource(
      fn -> {:cont, nil} end,
      fn
        :halt ->
          {:halt, :halt}

        {:cont, token} ->
          case fun.(token) do
            {:ok, %{next_token: nil} = response} -> {[response], :halt}
            {:ok, %{next_token: next} = response} -> {[response], {:cont, next}}
            {:error, error} -> raise error
          end
      end,
      fn _acc -> :ok end
    )
  end

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
