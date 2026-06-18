defmodule ReqAmazon.SpApi.ConfigTest do
  use ExUnit.Case, async: true

  alias ReqAmazon.SpApi.Config

  test "resolves endpoint and signing region from the region table" do
    assert %Config{endpoint: "https://sellingpartnerapi-eu.amazon.com", aws_region: "eu-west-1"} =
             Config.new(region: :eu)

    assert %Config{endpoint: "https://sellingpartnerapi-fe.amazon.com", aws_region: "us-west-2"} =
             Config.new(region: :fe)
  end

  test "does not sign or use sandbox by default" do
    config = Config.new()
    refute config.sign?
    refute config.sandbox?
  end

  test "explicit endpoint and aws_region override the region table" do
    config = Config.new(region: :eu, endpoint: "https://example.test", aws_region: "ap-south-1")
    assert config.endpoint == "https://example.test"
    assert config.aws_region == "ap-south-1"
  end

  test "raises on an unknown region" do
    assert_raise ArgumentError, ~r/unknown SP-API region/, fn -> Config.new(region: :mars) end
  end

  test "resolve/1 accepts a struct, a keyword list, or nil" do
    assert %Config{} = Config.resolve(nil)
    assert %Config{region: :fe} = Config.resolve(region: :fe)

    config = Config.new(region: :na)
    assert Config.resolve(config) == config
  end
end
