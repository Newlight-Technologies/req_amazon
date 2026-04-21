defmodule ReqAmazon.SpApi.ReportsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Reports}

  test "list_reports maps report filters", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/reports/2021-06-30/reports"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["reportTypes"] == "GET_FLAT_FILE_OPEN_LISTINGS_DATA"
      assert params["processingStatuses"] == "DONE,FATAL"
      assert params["createdSince"] == "2026-03-01T00:00:00Z"
      assert params["nextToken"] == "next-1"
      Req.Test.json(conn, %{"reports" => [%{"reportId" => "r-1"}], "nextToken" => nil})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"reports" => [%{"reportId" => "r-1"}], "nextToken" => nil}} =
             Reports.list_reports(req,
               report_types: ["GET_FLAT_FILE_OPEN_LISTINGS_DATA"],
               processing_statuses: ["DONE", "FATAL"],
               created_since: "2026-03-01T00:00:00Z",
               next_token: "next-1"
             )
  end

  test "create_report posts the raw body and get_report_document hits the document path", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/reports/2021-06-30/reports", "POST"} ->
          assert json_body(conn) == %{"reportType" => "GET_FLAT_FILE_OPEN_LISTINGS_DATA"}
          Req.Test.json(conn, %{"reportId" => "report-1"})

        {"sellingpartnerapi-na.amazon.com", "/reports/2021-06-30/documents/doc-1", "GET"} ->
          Req.Test.json(conn, %{"url" => "https://example.test/report.tsv"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"reportId" => "report-1"}} =
             Reports.create_report(req, %{"reportType" => "GET_FLAT_FILE_OPEN_LISTINGS_DATA"})

    assert {:ok, %{"url" => "https://example.test/report.tsv"}} =
             Reports.get_report_document(req, "doc-1")
  end
end
