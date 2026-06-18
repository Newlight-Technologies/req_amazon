defmodule ReqAmazon.SpApi.RateLimitTest do
  use ExUnit.Case, async: true

  alias ReqAmazon.SpApi.RateLimit

  defp response(status, headers \\ %{}) do
    %Req.Response{status: status, headers: headers, body: %{}}
  end

  test "429 with a rate limit and no Retry-After waits ~one token refill" do
    # 0.5 req/s -> one token every 2000 ms.
    assert {:delay, 2000} =
             RateLimit.retry(
               %Req.Request{},
               response(429, %{"x-amzn-ratelimit-limit" => ["0.5"]})
             )
  end

  test "429 caps the computed delay" do
    assert {:delay, delay} =
             RateLimit.retry(
               %Req.Request{},
               response(429, %{"x-amzn-ratelimit-limit" => ["0.00001"]})
             )

    assert delay == 30_000
  end

  test "429 with Retry-After defers to Req (returns true)" do
    assert RateLimit.retry(%Req.Request{}, response(429, %{"retry-after" => ["5"]})) == true
  end

  test "429 with neither header defers to Req (returns true)" do
    assert RateLimit.retry(%Req.Request{}, response(429)) == true
  end

  test "other transient statuses and transport errors retry like :transient" do
    assert RateLimit.retry(%Req.Request{}, response(503)) == true
    assert RateLimit.retry(%Req.Request{}, response(500)) == true
    assert RateLimit.retry(%Req.Request{}, %Req.TransportError{reason: :timeout}) == true
  end

  test "non-transient responses and errors are not retried" do
    assert RateLimit.retry(%Req.Request{}, response(404)) == false
    assert RateLimit.retry(%Req.Request{}, response(200)) == false
    assert RateLimit.retry(%Req.Request{}, %Req.TransportError{reason: :nxdomain}) == false
  end
end

defmodule ReqAmazon.SpApi.RateLimitIntegrationTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Orders, Response}

  test "a rate-limited 429 is retried and then succeeds", %{credentials: credentials} do
    counter = :counters.new(1, [:atomics])

    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/v0/orders/o-1"} =
        {conn.host, conn.request_path}

      attempt = :counters.get(counter, 1)
      :counters.add(counter, 1, 1)

      if attempt == 0 do
        conn
        |> Plug.Conn.put_resp_header("x-amzn-ratelimit-limit", "1000")
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          429,
          Jason.encode!(%{"errors" => [%{"code" => "QuotaExceeded", "message" => "slow down"}]})
        )
      else
        Req.Test.json(conn, %{"payload" => %{"AmazonOrderId" => "o-1"}})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"AmazonOrderId" => "o-1"}}} = Orders.get_order(req, "o-1")
    assert :counters.get(counter, 1) == 2
  end

  test "emits request telemetry with status, rate limit, and request id", %{
    credentials: credentials
  } do
    test_pid = self()
    handler = "rate-limit-telemetry-#{System.unique_integer([:positive])}"

    :telemetry.attach_many(
      handler,
      [[:req_amazon, :request, :start], [:req_amazon, :request, :stop]],
      fn event, measurements, metadata, _ ->
        send(test_pid, {:telemetry, event, measurements, metadata})
      end,
      nil
    )

    on_exit(fn -> :telemetry.detach(handler) end)

    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/orders/v0/orders/o-1"} =
        {conn.host, conn.request_path}

      conn
      |> Plug.Conn.put_resp_header("x-amzn-requestid", "req-7")
      |> Plug.Conn.put_resp_header("x-amzn-ratelimit-limit", "0.5")
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{"payload" => %{"AmazonOrderId" => "o-1"}}))
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})
    assert {:ok, %Response{}} = Orders.get_order(req, "o-1")

    assert_received {:telemetry, [:req_amazon, :request, :start], %{system_time: _},
                     %{method: :get, path: "/orders/v0/orders/o-1"}}

    assert_received {:telemetry, [:req_amazon, :request, :stop], %{duration: duration},
                     %{status: 200, request_id: "req-7", rate_limit: 0.5}}

    assert is_integer(duration)
  end
end
