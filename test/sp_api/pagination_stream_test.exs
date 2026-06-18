defmodule ReqAmazon.SpApi.PaginationStreamTest do
  use ExUnit.Case, async: true

  alias ReqAmazon.SpApi.{Error, Pagination, Response}

  defp page(items, next_token) do
    {:ok, %Response{body: %{"items" => items}, next_token: next_token, status: 200}}
  end

  test "follows next_token across pages and stops once it is nil" do
    pages = %{nil => page([1, 2], "t1"), "t1" => page([3], nil)}

    responses =
      Pagination.stream(fn token -> Map.fetch!(pages, token) end)
      |> Enum.to_list()

    assert Enum.map(responses, & &1.next_token) == ["t1", nil]
    assert Enum.flat_map(responses, & &1.body["items"]) == [1, 2, 3]
  end

  test "a single page yields one response" do
    assert [%Response{}] = Pagination.stream(fn nil -> page([1], nil) end) |> Enum.to_list()
  end

  test "raises the SP-API error on a failed page" do
    error = %Error{status: 429, errors: [], message: "throttled"}

    assert_raise Error, fn ->
      Pagination.stream(fn _token -> {:error, error} end) |> Enum.to_list()
    end
  end

  test "is lazy - only fetches the pages that are consumed" do
    counter = :counters.new(1, [:atomics])

    # Every page reports a next token, so the sequence is unbounded; a lazy
    # stream must still terminate under Enum.take/2 having fetched only one page.
    stream =
      Pagination.stream(fn _token ->
        :counters.add(counter, 1, 1)
        page([:item], "more")
      end)

    assert [%Response{}] = Enum.take(stream, 1)
    assert :counters.get(counter, 1) == 1
  end
end
