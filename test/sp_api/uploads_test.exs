defmodule ReqAmazon.SpApi.UploadsTest do
  use ReqAmazon.Case, async: false

  alias ReqAmazon.SpApi.{Client, Error, Uploads}

  test "create_upload_destination_for_resource maps params and escapes resource paths", %{
    credentials: credentials
  } do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/uploads/2020-11-01/uploadDestinations/aplus%2F2020-11-01%2FcontentDocuments%2Fimages"} =
        {conn.host, conn.request_path}

      params = query_params(conn)
      assert params["marketplaceIds"] == "ATVPDKIKX0DER"
      assert params["contentMD5"] == "8f14e45fceea167a5a36dedd4bea2543"
      assert params["contentType"] == "image/jpeg"

      Req.Test.json(conn, %{
        "payload" => %{
          "uploadDestinationId" => "dest-1",
          "url" => "https://aplus-media.example.test/upload"
        }
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:ok,
            %{
              "uploadDestinationId" => "dest-1",
              "url" => "https://aplus-media.example.test/upload"
            }} =
             Uploads.create_upload_destination_for_resource(
               req,
               "aplus/2020-11-01/contentDocuments/images",
               marketplace_ids: ["ATVPDKIKX0DER"],
               content_md5: "8f14e45fceea167a5a36dedd4bea2543",
               content_type: "image/jpeg"
             )
  end

  test "upload destination errors are wrapped", %{credentials: credentials} do
    stub_with_token(fn conn ->
      {"sellingpartnerapi-na.amazon.com",
       "/uploads/2020-11-01/uploadDestinations/aplus%2F2020-11-01%2FcontentDocuments%2Fimages"} =
        {conn.host, conn.request_path}

      json_response(conn, 400, %{
        "errors" => [%{"code" => "INVALID_INPUT", "message" => "Bad upload request"}]
      })
    end)

    req = Client.new(credentials: credentials, plug: {Req.Test, stub_name()})

    assert {:error, %Error{status: 400, errors: [%{"code" => "INVALID_INPUT"}]}} =
             Uploads.create_upload_destination_for_resource(
               req,
               "aplus/2020-11-01/contentDocuments/images",
               marketplace_ids: ["ATVPDKIKX0DER"],
               content_md5: "8f14e45fceea167a5a36dedd4bea2543"
             )
  end
end
