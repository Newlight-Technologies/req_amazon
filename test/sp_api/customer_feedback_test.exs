defmodule ReqAmazon.SpApi.CustomerFeedbackTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, CustomerFeedback, Error}

  test "get_browse_node_return_topics maps the current return topics endpoint", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/customerFeedback/2024-06-01/browseNodes/12345/returns/topics"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
      Req.Test.json(conn, %{"topics" => [%{"topic" => "Too small"}]})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"topics" => [%{"topic" => "Too small"}]}} =
             CustomerFeedback.get_browse_node_return_topics(req, "12345",
               marketplace_id: "ATVPDKIKX0DER"
             )
  end

  test "get_browse_node_return_trends escapes path params", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/customerFeedback/2024-06-01/browseNodes/12%2F345/returns/trends"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["marketplaceId"] == "ATVPDKIKX0DER"
      Req.Test.json(conn, %{"trends" => [%{"topic" => "Damaged"}]})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"trends" => [%{"topic" => "Damaged"}]}} =
             CustomerFeedback.get_browse_node_return_trends(req, "12/345",
               marketplace_id: "ATVPDKIKX0DER"
             )
  end

  test "customer feedback errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/customerFeedback/2024-06-01/browseNodes/12345/returns/topics"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_REQUEST", "message" => "Bad browse node"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_REQUEST"}]}} =
             CustomerFeedback.get_browse_node_return_topics(req, "12345",
               marketplace_id: "ATVPDKIKX0DER"
             )
  end
end
