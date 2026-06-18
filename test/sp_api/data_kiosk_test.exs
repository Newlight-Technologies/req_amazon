defmodule ReqAmazon.SpApi.DataKioskTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, DataKiosk, Error}

  test "get_queries maps filters and create_query posts the payload", %{credentials: credentials} do
    payload = %{"query" => "query { salesAndTrafficByDate { startDate } }"}

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/dataKiosk/2023-11-15/queries", "GET"} ->
          params = query_params(conn)
          assert params["processingStatuses"] == "DONE,FATAL"
          assert params["pageSize"] == "50"
          assert params["createdSince"] == "2026-03-01T00:00:00Z"
          assert params["createdUntil"] == "2026-03-15T00:00:00Z"
          assert params["paginationToken"] == "page-1"
          Req.Test.json(conn, %{"queries" => [%{"queryId" => "query-1"}]})

        {"sellingpartnerapi-na.amazon.com", "/dataKiosk/2023-11-15/queries", "POST"} ->
          assert json_body(conn) == payload
          Req.Test.json(conn, %{"queryId" => "query-1", "processingStatus" => "IN_QUEUE"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"queries" => [%{"queryId" => "query-1"}]}}} =
             DataKiosk.get_queries(req,
               processing_statuses: ["DONE", "FATAL"],
               page_size: 50,
               created_since: "2026-03-01T00:00:00Z",
               created_until: "2026-03-15T00:00:00Z",
               pagination_token: "page-1"
             )

    assert {:ok, %Response{body: %{"queryId" => "query-1", "processingStatus" => "IN_QUEUE"}}} =
             DataKiosk.create_query(req, payload)
  end

  test "get_query, cancel_query, and get_document escape path ids", %{credentials: credentials} do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/dataKiosk/2023-11-15/queries/query%2F1", "GET"} ->
          Req.Test.json(conn, %{"queryId" => "query/1", "processingStatus" => "DONE"})

        {"sellingpartnerapi-na.amazon.com", "/dataKiosk/2023-11-15/queries/query%2F1", "DELETE"} ->
          Req.Test.json(conn, %{"cancelled" => true})

        {"sellingpartnerapi-na.amazon.com", "/dataKiosk/2023-11-15/documents/doc%2F1", "GET"} ->
          Req.Test.json(conn, %{"documentId" => "doc/1", "url" => "https://example.test/doc/1"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"queryId" => "query/1", "processingStatus" => "DONE"}}} =
             DataKiosk.get_query(req, "query/1")

    assert {:ok, %Response{body: %{"cancelled" => true}}} = DataKiosk.cancel_query(req, "query/1")

    assert {:ok,
            %Response{body: %{"documentId" => "doc/1", "url" => "https://example.test/doc/1"}}} =
             DataKiosk.get_document(req, "doc/1")
  end

  test "data kiosk errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/dataKiosk/2023-11-15/queries/query-1"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad Data Kiosk query"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             DataKiosk.get_query(req, "query-1")
  end
end
