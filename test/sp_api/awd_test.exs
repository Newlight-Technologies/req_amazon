defmodule ReqAmazon.SpApi.AwdTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Response, Awd, Client}

  test "inbound shipment labels use modeled shipment paths", %{credentials: credentials} do
    stub_with_token(fn conn ->
      case {conn.host, conn.request_path, conn.method} do
        {"sellingpartnerapi-na.amazon.com", "/awd/2024-05-09/inboundShipments/ship%2F1/labels",
         "GET"} ->
          assert query_params(conn) == %{"pageType" => "A4", "formatType" => "PDF"}
          Req.Test.json(conn, %{"labels" => []})

        {"sellingpartnerapi-na.amazon.com",
         "/awd/2024-05-09/inboundShipments/ship%2F1/labelPageTypes", "GET"} ->
          Req.Test.json(conn, %{"pageTypes" => ["A4"]})
      end
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok, %Response{body: %{"labels" => []}}} =
             Awd.get_inbound_shipment_labels(req, "ship/1", page_type: "A4", format_type: "PDF")

    assert {:ok, %Response{body: %{"pageTypes" => ["A4"]}}} =
             Awd.get_inbound_shipment_label_page_types(req, "ship/1")
  end
end
