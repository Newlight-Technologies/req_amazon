defmodule ReqAmazon.SpApi.NotificationsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, Notifications}

  test "subscription operations hit the expected paths and payloads", %{credentials: credentials} do
    subscription_payload = %{
      "payloadVersion" => "2023-11-15",
      "destinationId" => "dest-1"
    }

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com",
         "/notifications/v1/subscriptions/DATA_KIOSK_QUERY_PROCESSING_FINISHED", "GET"} ->
          assert query_params(conn) == %{}
          Req.Test.json(conn, %{"payload" => %{"subscriptionId" => "sub-1"}})

        {"sellingpartnerapi-na.amazon.com",
         "/notifications/v1/subscriptions/DATA_KIOSK_QUERY_PROCESSING_FINISHED", "POST"} ->
          assert json_body(conn) == subscription_payload
          Req.Test.json(conn, %{"payload" => %{"subscriptionId" => "sub-1"}})

        {"sellingpartnerapi-na.amazon.com",
         "/notifications/v1/subscriptions/DATA_KIOSK_QUERY_PROCESSING_FINISHED/testNotification",
         "POST"} ->
          assert json_body(conn) == %{"destinationId" => "dest-1"}
          Req.Test.json(conn, %{"payload" => %{"testNotificationId" => "test-1"}})

        {"sellingpartnerapi-na.amazon.com",
         "/notifications/v1/subscriptions/DATA_KIOSK_QUERY_PROCESSING_FINISHED/sub%2F1", "GET"} ->
          Req.Test.json(conn, %{"payload" => %{"subscriptionId" => "sub/1"}})

        {"sellingpartnerapi-na.amazon.com",
         "/notifications/v1/subscriptions/DATA_KIOSK_QUERY_PROCESSING_FINISHED/sub%2F1", "DELETE"} ->
          Req.Test.json(conn, %{"payload" => %{"deleted" => true}})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"subscriptionId" => "sub-1"}} =
             Notifications.get_subscription(req, "DATA_KIOSK_QUERY_PROCESSING_FINISHED")

    assert {:ok, %{"subscriptionId" => "sub-1"}} =
             Notifications.create_subscription(
               req,
               "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
               subscription_payload
             )

    assert {:ok, %{"testNotificationId" => "test-1"}} =
             Notifications.send_test_notification(
               req,
               "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
               %{"destinationId" => "dest-1"}
             )

    assert {:ok, %{"subscriptionId" => "sub/1"}} =
             Notifications.get_subscription_by_id(
               req,
               "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
               "sub/1"
             )

    assert {:ok, %{"deleted" => true}} =
             Notifications.delete_subscription_by_id(
               req,
               "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
               "sub/1"
             )
  end

  test "get_subscription can target a payload version", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/notifications/v1/subscriptions/DATA_KIOSK_QUERY_PROCESSING_FINISHED", "GET"} =
        {conn.host, conn.request_path, conn.method}

      assert query_params(conn) == %{"payloadVersion" => "2023-11-15"}

      Req.Test.json(conn, %{"payload" => %{"subscriptionId" => "sub-1"}})
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %{"subscriptionId" => "sub-1"}} =
             Notifications.get_subscription(req, "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
               payload_version: "2023-11-15"
             )
  end

  test "destination operations hit the expected paths and payloads", %{credentials: credentials} do
    destination_payload = %{
      "name" => "Data Kiosk Queue",
      "resourceSpecification" => %{"sqs" => %{"arn" => "arn:aws:sqs:us-east-1:123456789012:q"}}
    }

    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/notifications/v1/destinations", "GET"} ->
          Req.Test.json(conn, %{"payload" => [%{"destinationId" => "dest-1"}]})

        {"sellingpartnerapi-na.amazon.com", "/notifications/v1/destinations", "POST"} ->
          assert json_body(conn) == destination_payload
          Req.Test.json(conn, %{"payload" => %{"destinationId" => "dest-1"}})

        {"sellingpartnerapi-na.amazon.com", "/notifications/v1/destinations/dest%2F1", "GET"} ->
          Req.Test.json(conn, %{"payload" => %{"destinationId" => "dest/1"}})

        {"sellingpartnerapi-na.amazon.com", "/notifications/v1/destinations/dest%2F1", "DELETE"} ->
          Req.Test.json(conn, %{"payload" => %{"deleted" => true}})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, [%{"destinationId" => "dest-1"}]} = Notifications.get_destinations(req)

    assert {:ok, %{"destinationId" => "dest-1"}} =
             Notifications.create_destination(req, destination_payload)

    assert {:ok, %{"destinationId" => "dest/1"}} =
             Notifications.get_destination(req, "dest/1")

    assert {:ok, %{"deleted" => true}} = Notifications.delete_destination(req, "dest/1")
  end

  test "notifications errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com", "/notifications/v1/destinations/dest-1"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad notification request"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             Notifications.get_destination(req, "dest-1")
  end
end
