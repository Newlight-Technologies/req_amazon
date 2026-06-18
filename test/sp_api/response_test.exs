defmodule ReqAmazon.SpApi.ResponseTest do
  use ExUnit.Case, async: true

  alias ReqAmazon.SpApi.{Error, Pagination, Response}

  describe "Pagination.next_token/1" do
    test "finds nested pagination.nextToken (newer APIs)" do
      assert Pagination.next_token(%{"items" => [], "pagination" => %{"nextToken" => "abc"}}) ==
               "abc"
    end

    test "finds payload-nested NextToken (Orders/Finances v0)" do
      assert Pagination.next_token(%{"payload" => %{"Orders" => [], "NextToken" => "tok"}}) ==
               "tok"
    end

    test "accepts pagination.paginationToken as a fallback" do
      assert Pagination.next_token(%{"pagination" => %{"paginationToken" => "pt"}}) == "pt"
    end

    test "finds top-level nextToken (Reports)" do
      assert Pagination.next_token(%{"reports" => [], "nextToken" => "r"}) == "r"
    end

    test "finds pagination as a sibling of payload (FBA Inventory)" do
      body = %{
        "payload" => %{"inventorySummaries" => []},
        "pagination" => %{"nextToken" => "fba"}
      }

      assert Pagination.next_token(body) == "fba"
    end

    test "returns nil when there is no next page" do
      assert Pagination.next_token(%{"reports" => []}) == nil
      assert Pagination.next_token(%{"nextToken" => ""}) == nil
      assert Pagination.next_token(%{"pagination" => %{}}) == nil
      assert Pagination.next_token("not a map") == nil
    end
  end

  describe "Response.from_req/1" do
    test "strips the payload envelope and normalizes token + throttling metadata" do
      response = %Req.Response{
        status: 200,
        headers: %{
          "x-amzn-requestid" => ["req-123"],
          "x-amzn-ratelimit-limit" => ["0.5"]
        },
        body: %{"payload" => %{"Orders" => [%{"id" => 1}], "NextToken" => "next"}}
      }

      assert %Response{
               body: %{"Orders" => [%{"id" => 1}], "NextToken" => "next"},
               status: 200,
               next_token: "next",
               rate_limit: 0.5,
               request_id: "req-123"
             } = Response.from_req(response)
    end

    test "leaves rate_limit/request_id nil when Amazon omits the headers" do
      response = %Req.Response{status: 200, headers: %{}, body: %{"reports" => []}}

      assert %Response{
               rate_limit: nil,
               request_id: nil,
               next_token: nil,
               body: %{"reports" => []}
             } =
               Response.from_req(response)
    end
  end

  describe "Error throttling metadata" do
    test "from_response/3 carries request id, retry-after, and rate limit" do
      error =
        Error.from_response(
          429,
          %{"errors" => [%{"code" => "QuotaExceeded", "message" => "slow down"}]},
          request_id: "req-9",
          retry_after: 30,
          rate_limit: 0.0167
        )

      assert %Error{status: 429, request_id: "req-9", retry_after: 30, rate_limit: 0.0167} = error
    end

    test "wrap/1 recovers throttling metadata from a 429 Req.Response" do
      response = %Req.Response{
        status: 429,
        headers: %{
          "x-amzn-requestid" => ["req-x"],
          "retry-after" => ["12"],
          "x-amzn-ratelimit-limit" => ["0.5"]
        },
        body: %{"errors" => [%{"code" => "QuotaExceeded", "message" => "slow down"}]}
      }

      assert %Error{status: 429, request_id: "req-x", retry_after: 12, rate_limit: 0.5} =
               Error.wrap(response)
    end
  end
end
