defmodule ReqAmazon.SpApi.FinancesV20240619Test do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, FinancesV2, FinancesV20240619}

  test "list_transactions maps current query params including transaction status", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/finances/2024-06-19/transactions"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["postedAfter"] == "2026-03-01T00:00:00Z"
      assert params["postedBefore"] == "2026-03-15T00:00:00Z"
      assert params["marketplaceId"] == "ATVPDKIKX0DER"
      assert params["transactionStatus"] == "RELEASED"
      assert params["nextToken"] == "next-2"

      Req.Test.json(conn, %{
        "transactions" => [%{"transactionId" => "txn-1"}],
        "nextToken" => nil
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"transactions" => [%{"transactionId" => "txn-1"}], "nextToken" => nil}} =
             FinancesV20240619.list_transactions(req,
               posted_after: "2026-03-01T00:00:00Z",
               posted_before: "2026-03-15T00:00:00Z",
               marketplace_id: "ATVPDKIKX0DER",
               transaction_status: "RELEASED",
               next_token: "next-2"
             )
  end

  test "list_transactions allows marketplace filters to be omitted", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/finances/2024-06-19/transactions"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["postedAfter"] == "2026-03-01T00:00:00Z"
      refute Map.has_key?(params, "marketplaceId")
      refute Map.has_key?(params, "transactionStatus")

      Req.Test.json(conn, %{"transactions" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"transactions" => []}} =
             FinancesV20240619.list_transactions(req, posted_after: "2026-03-01T00:00:00Z")
  end

  test "finances v2024 errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/finances/2024-06-19/transactions"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad transaction request"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             FinancesV20240619.list_transactions(req, posted_after: "2026-03-01T00:00:00Z")
  end

  test "FinancesV2 remains as a compatibility delegate", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/finances/2024-06-19/transactions"} =
        {conn.host, conn.request_path}

      assert query_params(conn)["postedAfter"] == "2026-03-01T00:00:00Z"
      Req.Test.json(conn, %{"transactions" => []})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"transactions" => []}} =
             apply(FinancesV2, :list_transactions, [req, [posted_after: "2026-03-01T00:00:00Z"]])
  end
end
