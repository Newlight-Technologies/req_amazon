# ReqAmazon

`ReqAmazon` provides a thin `Req` plugin and low-level Amazon Selling Partner API wrappers.

The library is intentionally version-aware. When Amazon ships a materially different API version, `req_amazon` keeps legacy and current wrappers side by side instead of silently re-pointing an existing module.

The project is currently intended to be consumed directly from Git rather than Hex.

## Installation

Add `req_amazon` as a git dependency in `mix.exs`:

```elixir
def deps do
  [
    {:req_amazon, git: "https://github.com/Newlight-Technologies/req_amazon.git", ref: "<commit-or-tag>"}
  ]
end
```

Prefer pinning consuming applications to a commit or tag instead of tracking `main`.

## Credentials And Configuration

When `req_amazon` manages Login with Amazon token refresh for you, provide full SP-API credentials:

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

Optional application config:

```elixir
config :req_amazon,
  sp_api_endpoint: "https://sellingpartnerapi-na.amazon.com",
  sp_api_token_url: "https://api.amazon.com/auth/o2/token",
  sp_api_user_agent: "my_app/1.0.0 (Elixir)"
```

If your application already manages LWA refresh and wants to pass a caller-managed access token, only the AWS signing credentials are required:

```elixir
%{
  aws_access_key_id: System.fetch_env!("AMAZON_SP_API_AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.fetch_env!("AMAZON_SP_API_AWS_SECRET_ACCESS_KEY"),
  aws_region: System.get_env("AMAZON_SP_API_AWS_REGION", "us-east-1")
}
```

## Building Requests

### `ReqAmazon.SpApi.Client.new/1`

Use `Client.new/1` when you want a ready-to-call `Req.Request` with the SP-API plugin attached:

```elixir
req =
  ReqAmazon.SpApi.Client.new(
    credentials: %{
      client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
      client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET"),
      refresh_token: System.fetch_env!("AMAZON_SP_API_REFRESH_TOKEN"),
      aws_access_key_id: System.fetch_env!("AMAZON_SP_API_AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.fetch_env!("AMAZON_SP_API_AWS_SECRET_ACCESS_KEY"),
      aws_region: "us-east-1"
    }
  )
```

### `ReqAmazon.SpApi.attach/2`

Use `attach/2` when you already have a `Req` request and want to add the SP-API transport behavior yourself:

```elixir
req =
  Req.new(base_url: "https://sellingpartnerapi-na.amazon.com")
  |> ReqAmazon.SpApi.attach(credentials: %{...})
```

`attach/2` is the lower-level building block. `Client.new/1` is the convenience wrapper around it.

### Caller-Managed Access Tokens

If your application refreshes LWA tokens itself, pass the access token with `:access_token`:

```elixir
req =
  ReqAmazon.SpApi.Client.new(
    base_url: "https://sellingpartnerapi-eu.amazon.com",
    access_token: token,
    credentials: %{
      aws_access_key_id: System.fetch_env!("AMAZON_SP_API_AWS_ACCESS_KEY_ID"),
      aws_secret_access_key: System.fetch_env!("AMAZON_SP_API_AWS_SECRET_ACCESS_KEY"),
      aws_region: "eu-west-1"
    }
  )
```

You can also inject the header yourself before calling `attach/2`:

```elixir
req =
  Req.new(base_url: "https://sellingpartnerapi-na.amazon.com")
  |> Req.Request.put_header("x-amz-access-token", token)
  |> ReqAmazon.SpApi.attach(credentials: %{aws_access_key_id: "...", aws_secret_access_key: "..."})
```

### Endpoint And Region Overrides

Per Amazon's SP-API endpoint documentation, the standard regional hosts are:

- North America: `https://sellingpartnerapi-na.amazon.com` with AWS region `us-east-1`
- Europe: `https://sellingpartnerapi-eu.amazon.com` with AWS region `eu-west-1`
- Far East: `https://sellingpartnerapi-fe.amazon.com` with AWS region `us-west-2`

Override both the request `base_url` and the signing `aws_region` together when you target a different region.

## Wrapper Conventions

The public endpoint modules follow these conventions:

- Path params are positional function args.
- Optional query params are keyword opts.
- Request bodies are explicit map args.
- Elixir opts use `snake_case`.
- Modules convert Elixir opts to Amazon's exact path and query names internally.
- Current and legacy versions stay side by side when Amazon revs a family in a breaking way.
- Versioned file and module naming follow `orders_v2026_01_01.ex` -> `ReqAmazon.SpApi.OrdersV20260101`.

## Versioning Policy

`req_amazon` keeps legacy and current wrappers side by side instead of breaking old callers by renaming the plain module in place.

Current examples:

- `ReqAmazon.SpApi.Orders` keeps the legacy Orders `v0` wrapper.
- `ReqAmazon.SpApi.OrdersV20260101` wraps the current Orders `v2026-01-01` API.
- `ReqAmazon.SpApi.Finances` and `ReqAmazon.SpApi.FinancesV2` keep legacy and current finance surfaces separate.
- `ReqAmazon.SpApi.Pricing` keeps the legacy Product Pricing `v0` wrapper.
- `ReqAmazon.SpApi.PricingV20220501` wraps the current Product Pricing `v2022-05-01` API.

See [docs/api_version_matrix.md](docs/api_version_matrix.md) for the repo-wide matrix and [docs/sp_api_parity_checklist.md](docs/sp_api_parity_checklist.md) for the parity policy and audit notes from this pass.

## Examples

Reports:

```elixir
ReqAmazon.SpApi.Reports.get_report(req, "report-id")
```

Listings validation preview:

```elixir
ReqAmazon.SpApi.Listings.put_listings_item(
  req,
  "SELLER1",
  "SKU-001",
  [
    marketplace_ids: ["ATVPDKIKX0DER"],
    included_data: ["issues", "identifiers"],
    mode: "VALIDATION_PREVIEW",
    issue_locale: "en_US"
  ],
  %{
    "productType" => "PRODUCT",
    "requirements" => "LISTING",
    "attributes" => %{}
  }
)
```

Current Orders API:

```elixir
ReqAmazon.SpApi.OrdersV20260101.search_orders(
  req,
  created_after: "2026-03-01T00:00:00Z",
  marketplace_ids: ["ATVPDKIKX0DER"],
  included_data: ["BUYER", "RECIPIENT"]
)
```

Current Pricing API:

```elixir
ReqAmazon.SpApi.PricingV20220501.get_competitive_summary(
  req,
  %{
    "requests" => [
      %{"asin" => "B000123", "marketplaceId" => "ATVPDKIKX0DER"}
    ]
  }
)
```

A+ Content:

```elixir
ReqAmazon.SpApi.APlusContent.search_content_documents(
  req,
  marketplace_id: "ATVPDKIKX0DER"
)
```

Product Type Definitions:

```elixir
ReqAmazon.SpApi.ProductTypeDefinitions.get_definitions_product_type(
  req,
  "LUGGAGE",
  marketplace_ids: ["ATVPDKIKX0DER"],
  seller_id: "SELLER1",
  requirements: "LISTING",
  locale: "en_US"
)
```

## Supported Public API

The intended public entrypoints are:

- `ReqAmazon`
- `ReqAmazon.SpApi`
- `ReqAmazon.SpApi.Client`
- `ReqAmazon.SpApi.*` endpoint modules used to call Amazon APIs

Internal implementation modules such as token caching, signing helpers, and application boot code may change without notice.

## Development

Run the test suite with:

```bash
mix test
mix compile
```

The repository does not ship any real credentials. The tests use stubbed requests and synthetic values only.
