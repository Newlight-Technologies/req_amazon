defmodule ReqAmazon.SpApi.FinancesTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Finances}

  test "list_financial_event_groups maps date filters", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/finances/v0/financialEventGroups"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["FinancialEventGroupStartedAfter"] == "2026-03-01T00:00:00Z"
      assert params["FinancialEventGroupStartedBefore"] == "2026-03-15T00:00:00Z"
      assert params["NextToken"] == "next-1"

      Req.Test.json(conn, %{
        "payload" => %{"FinancialEventGroupList" => [], "NextToken" => nil}
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"FinancialEventGroupList" => [], "NextToken" => nil}} =
             Finances.list_financial_event_groups(req,
               financial_event_group_started_after: "2026-03-01T00:00:00Z",
               financial_event_group_started_before: "2026-03-15T00:00:00Z",
               next_token: "next-1"
             )
  end
end
