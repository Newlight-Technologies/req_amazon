# ReqAmazon

`ReqAmazon` provides `Req` plugins and thin API clients for Amazon's Selling Partner APIs.

The project is currently intended to be consumed directly from Git rather than Hex.

## Installation

Add `req_amazon` as a git dependency in `mix.exs`:

```elixir
def deps do
  [
    {:req_amazon, git: "https://github.com/Newlight-Technologies/req_amazon.git", branch: "main"}
  ]
end
```

## Configuration

You can provide default SP-API credentials through application config:

```elixir
config :req_amazon,
  sp_api_credentials: %{
    client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
    client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET"),
    refresh_token: System.fetch_env!("AMAZON_SP_API_REFRESH_TOKEN"),
    aws_access_key_id: System.fetch_env!("AMAZON_SP_API_AWS_ACCESS_KEY_ID"),
    aws_secret_access_key: System.fetch_env!("AMAZON_SP_API_AWS_SECRET_ACCESS_KEY"),
    aws_region: System.get_env("AMAZON_SP_API_AWS_REGION", "us-east-1")
  }
```

You can also pass credentials directly when attaching the plugin or building a client.

## Usage

Build a configured client:

```elixir
req =
  ReqAmazon.SpApi.Client.new(
    credentials: %{
      client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
      client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET"),
      refresh_token: System.fetch_env!("AMAZON_SP_API_REFRESH_TOKEN"),
      aws_access_key_id: System.fetch_env!("AMAZON_SP_API_AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.fetch_env!("AMAZON_SP_API_AWS_SECRET_ACCESS_KEY")
    }
  )

ReqAmazon.SpApi.Orders.list_orders(
  req,
  marketplace_ids: ["ATVPDKIKX0DER"],
  created_after: "2024-01-01T00:00:00Z"
)
```

Attach the plugin to an existing request:

```elixir
req =
  Req.new(base_url: ReqAmazon.SpApi.endpoint())
  |> ReqAmazon.SpApi.attach(credentials: %{...})

ReqAmazon.SpApi.Reports.get_report(req, "report-id")
```

## Supported Public API

The intended public entrypoints are:

- `ReqAmazon`
- `ReqAmazon.SpApi`
- `ReqAmazon.SpApi.Client`
- `ReqAmazon.SpApi.*` endpoint modules used to call Amazon APIs

Internal implementation modules such as token caching, request signing helpers, and application boot code may change without notice.

## Development

Run the test suite with:

```bash
mix test
```

The repository does not ship any real credentials. The tests use stubbed requests and synthetic values only.
