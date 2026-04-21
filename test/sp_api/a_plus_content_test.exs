defmodule ReqAmazon.SpApi.APlusContentTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{APlusContent, Client, Error}

  test "search_content_documents and get_content_document map query params", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentDocuments", "GET"} ->
          params = query_params(conn)
          assert params["marketplaceId"] == "ATVPDKIKX0DER"
          assert params["pageToken"] == "page-1"
          Req.Test.json(conn, %{"contentMetadataRecords" => [%{"name" => "Brand Story"}]})

        {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentDocuments/ref%2Fkey-1",
         "GET"} ->
          params = query_params(conn)
          assert params["marketplaceId"] == "ATVPDKIKX0DER"
          assert params["includedDataSet"] == "METADATA,CONTENTS"
          Req.Test.json(conn, %{"contentDocument" => %{"name" => "Brand Story"}})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"contentMetadataRecords" => [%{"name" => "Brand Story"}]}} =
             APlusContent.search_content_documents(req,
               marketplace_id: "ATVPDKIKX0DER",
               page_token: "page-1"
             )

    assert {:ok, %{"contentDocument" => %{"name" => "Brand Story"}}} =
             APlusContent.get_content_document(req, "ref/key-1",
               marketplace_id: "ATVPDKIKX0DER",
               included_data_set: ["METADATA", "CONTENTS"]
             )
  end

  test "create_content_document and update_content_document post payloads", %{
    credentials: credentials
  } do
    payload = %{
      "contentDocument" => %{
        "name" => "Brand Story - Core Collection",
        "contentType" => "EMC",
        "locale" => "en-US",
        "contentModuleList" => []
      }
    }

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentDocuments", "POST"} ->
          assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
          assert json_body(conn) == payload
          Req.Test.json(conn, %{"contentReferenceKey" => "ref-key-1"})

        {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentDocuments/ref%2Fkey-1",
         "POST"} ->
          assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
          assert json_body(conn) == payload
          Req.Test.json(conn, %{"warnings" => []})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"contentReferenceKey" => "ref-key-1"}} =
             APlusContent.create_content_document(req, [marketplace_id: "ATVPDKIKX0DER"], payload)

    assert {:ok, %{"warnings" => []}} =
             APlusContent.update_content_document(
               req,
               "ref/key-1",
               [marketplace_id: "ATVPDKIKX0DER"],
               payload
             )
  end

  test "asin relation operations map params and payloads", %{credentials: credentials} do
    relation_payload = %{"asinSet" => ["B000123456", "B000654321"]}
    validation_payload = %{"asinSet" => ["B000123456"], "contentDocument" => %{"name" => "X"}}

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com",
         "/aplus/2020-11-01/contentDocuments/ref%2Fkey-1/asins", "GET"} ->
          params = query_params(conn)
          assert params["marketplaceId"] == "ATVPDKIKX0DER"
          assert params["pageToken"] == "page-2"
          Req.Test.json(conn, %{"asinMetadataSet" => [%{"asin" => "B000123456"}]})

        {"sellingpartnerapi-na.amazon.com",
         "/aplus/2020-11-01/contentDocuments/ref%2Fkey-1/asins", "POST"} ->
          assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
          assert json_body(conn) == relation_payload
          Req.Test.json(conn, %{"warnings" => []})

        {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentAsinValidations", "POST"} ->
          assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
          assert json_body(conn) == validation_payload
          Req.Test.json(conn, %{"warnings" => []})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"asinMetadataSet" => [%{"asin" => "B000123456"}]}} =
             APlusContent.list_content_document_asin_relations(req, "ref/key-1",
               marketplace_id: "ATVPDKIKX0DER",
               page_token: "page-2"
             )

    assert {:ok, %{"warnings" => []}} =
             APlusContent.post_content_document_asin_relations(
               req,
               "ref/key-1",
               [marketplace_id: "ATVPDKIKX0DER"],
               relation_payload
             )

    assert {:ok, %{"warnings" => []}} =
             APlusContent.validate_content_document_asin_relations(
               req,
               [marketplace_id: "ATVPDKIKX0DER"],
               validation_payload
             )
  end

  test "publish record, approval, and suspension operations hit the expected endpoints", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentPublishRecords", "GET"} ->
          params = query_params(conn)
          assert params["marketplaceId"] == "ATVPDKIKX0DER"
          assert params["asin"] == "B000123456"
          assert params["pageToken"] == "page-3"
          Req.Test.json(conn, %{"publishRecordList" => [%{"contentReferenceKey" => "ref-key-1"}]})

        {"sellingpartnerapi-na.amazon.com",
         "/aplus/2020-11-01/contentDocuments/ref%2Fkey-1/approvalSubmissions", "POST"} ->
          assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
          Req.Test.json(conn, %{"warnings" => []})

        {"sellingpartnerapi-na.amazon.com",
         "/aplus/2020-11-01/contentDocuments/ref%2Fkey-1/suspendSubmissions", "POST"} ->
          assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
          Req.Test.json(conn, %{"warnings" => []})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"publishRecordList" => [%{"contentReferenceKey" => "ref-key-1"}]}} =
             APlusContent.search_content_publish_records(req,
               marketplace_id: "ATVPDKIKX0DER",
               asin: "B000123456",
               page_token: "page-3"
             )

    assert {:ok, %{"warnings" => []}} =
             APlusContent.post_content_document_approval_submission(req, "ref/key-1",
               marketplace_id: "ATVPDKIKX0DER"
             )

    assert {:ok, %{"warnings" => []}} =
             APlusContent.post_content_document_suspend_submission(req, "ref/key-1",
               marketplace_id: "ATVPDKIKX0DER"
             )
  end

  test "a+ content errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/aplus/2020-11-01/contentDocuments/ref-key-1"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad content document"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             APlusContent.get_content_document(req, "ref-key-1", marketplace_id: "ATVPDKIKX0DER")
  end
end
