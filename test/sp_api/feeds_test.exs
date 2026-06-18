defmodule ReqAmazon.SpApi.FeedsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Client, Feeds}

  test "create_feed_document posts content type body", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/feeds/2021-06-30/documents"} =
        {conn.host, conn.request_path}

      assert json_body(conn) == %{"contentType" => "text/tab-separated-values; charset=UTF-8"}

      Req.Test.json(conn, %{
        "feedDocumentId" => "doc-1",
        "url" => "https://example.test/upload"
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok,
            %Response{
              body: %{"feedDocumentId" => "doc-1", "url" => "https://example.test/upload"}
            }} =
             Feeds.create_feed_document(req, "text/tab-separated-values; charset=UTF-8")
  end

  test "create_feed and cancel_feed hit the expected endpoints", %{credentials: credentials} do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/feeds/2021-06-30/feeds", "POST"} ->
          assert json_body(conn) == %{"feedType" => "POST_FLAT_FILE_LISTINGS_DATA"}
          Req.Test.json(conn, %{"feedId" => "feed-1"})

        {"sellingpartnerapi-na.amazon.com", "/feeds/2021-06-30/feeds/feed-1", "DELETE"} ->
          Req.Test.json(conn, %{"payload" => %{"cancelled" => true}})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"feedId" => "feed-1"}}} =
             Feeds.create_feed(req, %{"feedType" => "POST_FLAT_FILE_LISTINGS_DATA"})

    assert {:ok, %Response{body: %{"cancelled" => true}}} = Feeds.cancel_feed(req, "feed-1")
  end
end
