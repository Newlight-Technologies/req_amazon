defmodule ReqAmazon.MixProject do
  use Mix.Project

  def project do
    [
      app: :req_amazon,
      version: "0.2.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ReqAmazon.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:telemetry, "~> 1.0"},
      {:plug, "~> 1.15", only: :test}
    ]
  end

  defp description do
    "Req plugins and thin API clients for Amazon Selling Partner APIs"
  end

  defp package do
    [
      licenses: ["MIT"]
    ]
  end
end
