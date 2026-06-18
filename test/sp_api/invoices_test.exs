defmodule ReqAmazon.SpApi.InvoicesTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, Invoices}

  test "invoice attributes and documents use modeled paths", %{credentials: credentials} do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/tax/invoices/2024-06-19/attributes", "GET"} ->
          assert query_params(conn) == %{"marketplaceId" => "ATVPDKIKX0DER"}
          Req.Test.json(conn, %{"attributes" => []})

        {"sellingpartnerapi-na.amazon.com", "/tax/invoices/2024-06-19/documents/doc%2F1", "GET"} ->
          assert query_params(conn) == %{}
          Req.Test.json(conn, %{"url" => "https://example.test/invoice.pdf"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"attributes" => []}}} =
             Invoices.get_invoices_attributes(req, marketplace_id: "ATVPDKIKX0DER")

    assert {:ok, %Response{body: %{"url" => "https://example.test/invoice.pdf"}}} =
             Invoices.get_invoices_document(req, "doc/1")
  end

  test "invoice exports use modeled paths and filters", %{credentials: credentials} do
    payload = %{"marketplaceId" => "ATVPDKIKX0DER"}

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/tax/invoices/2024-06-19/exports", "POST"} ->
          assert json_body(conn) == payload
          Req.Test.json(conn, %{"exportId" => "export-1"})

        {"sellingpartnerapi-na.amazon.com", "/tax/invoices/2024-06-19/exports", "GET"} ->
          params = query_params(conn)
          assert params["marketplaceId"] == "ATVPDKIKX0DER"
          assert params["dateStart"] == "2026-06-01T00:00:00Z"
          assert params["dateEnd"] == "2026-06-02T00:00:00Z"
          assert params["status"] == "DONE"
          assert params["pageSize"] == "25"
          assert params["nextToken"] == "next-1"
          Req.Test.json(conn, %{"exports" => []})

        {"sellingpartnerapi-na.amazon.com", "/tax/invoices/2024-06-19/exports/export-1", "GET"} ->
          Req.Test.json(conn, %{"exportId" => "export-1"})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"exportId" => "export-1"}}} =
             Invoices.create_invoices_export(req, payload)

    assert {:ok, %Response{body: %{"exports" => []}}} =
             Invoices.get_invoices_exports(req,
               marketplace_id: "ATVPDKIKX0DER",
               date_start: "2026-06-01T00:00:00Z",
               date_end: "2026-06-02T00:00:00Z",
               status: "DONE",
               page_size: 25,
               next_token: "next-1"
             )

    assert {:ok, %Response{body: %{"exportId" => "export-1"}}} =
             Invoices.get_invoices_export(req, "export-1")
  end
end
