defmodule ReqAmazon.SpApi.ReportsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, Reports}

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
          assert query_params(conn) == %{}
          Req.Test.json(conn, %{"url" => "https://example.test/report.tsv"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"reportId" => "report-1"}} =
             Reports.create_report(req, %{"reportType" => "GET_FLAT_FILE_OPEN_LISTINGS_DATA"})

    assert {:ok, %{"url" => "https://example.test/report.tsv"}} =
             Reports.get_report_document(req, "doc-1")
  end

  test "get_report_document can request a content-encoding URL header", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/reports/2021-06-30/documents/doc-1", "GET"} =
        {conn.host, conn.request_path, conn.method}

      assert query_params(conn) == %{"enableContentEncodingUrlHeader" => "true"}

      Req.Test.json(conn, %{
        "url" => "https://example.test/report.tsv.gz",
        "compressionAlgorithm" => "GZIP"
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"compressionAlgorithm" => "GZIP"}} =
             Reports.get_report_document(req, "doc-1", enable_content_encoding_url_header: true)
  end

  test "stream_report_document streams the temporary report URL", %{credentials: credentials} do
    test_pid = self()

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/reports/2021-06-30/documents/doc-1", "GET"} ->
          assert query_params(conn) == %{"enableContentEncodingUrlHeader" => "false"}

          Req.Test.json(conn, %{
            "url" => "https://reports.amazon.test/report.tsv",
            "compressionAlgorithm" => "GZIP"
          })

        {"reports.amazon.test", "/report.tsv", "GET"} ->
          assert Plug.Conn.get_req_header(conn, "authorization") == []
          assert Plug.Conn.get_req_header(conn, "x-amz-access-token") == []

          conn
          |> Plug.Conn.put_resp_content_type("text/tab-separated-values")
          |> Plug.Conn.send_resp(200, "sku\tqty\nABC\t1\n")
      end
    end)

    into = fn {:data, data}, {req, response} ->
      send(test_pid, {:report_chunk, data})
      {:cont, {req, response}}
    end

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{document: %{"compressionAlgorithm" => "GZIP"}, response: response}} =
             Reports.stream_report_document(req, "doc-1", into,
               enable_content_encoding_url_header: false,
               plug: {Req.Test, stub_name()}
             )

    assert response.status == 200
    assert_received {:report_chunk, "sku\tqty\nABC\t1\n"}
  end

  test "download_report_document reports missing URLs" do
    assert {:error,
            %Error{
              status: nil,
              errors: [%{"code" => "MissingReportDocumentUrl"} | _]
            }} = Reports.download_report_document(%{}, fn _, acc -> {:cont, acc} end)
  end
end
