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

When `req_amazon` manages Login with Amazon token refresh for you, provide the
LWA credentials:

```elixir
config :req_amazon,
  sp_api_credentials: %{
    client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
    client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET"),
    refresh_token: System.fetch_env!("AMAZON_SP_API_REFRESH_TOKEN")
  }
```

> **AWS signing is opt-in.** Amazon no longer requires AWS SigV4 on SP-API calls —
> the LWA access token is enough — so `aws_access_key_id`/`aws_secret_access_key`
> are **only** needed when you pass `sign?: true`. Configure the endpoint with
> `region:` (`:na` | `:eu` | `:fe`) rather than hardcoding a URL.

Optional application config:

```elixir
config :req_amazon,
  sp_api_endpoint: "https://sellingpartnerapi-na.amazon.com",
  sp_api_token_url: "https://api.amazon.com/auth/o2/token",
  sp_api_user_agent: "my_app/1.0.0 (Elixir)",
  # Override how LWA tokens are minted (default: ReqAmazon.SpApi.Token.Lwa).
  token_provider: MyApp.TokenProvider
```

Access tokens are cached and refreshed automatically. Concurrent requests for the
same credentials share a single in-flight refresh (single-flight), so a fleet of
workers never stampedes Amazon's token endpoint.

If your application already manages LWA refresh and passes a caller-managed
access token (`access_token:`), no credentials are required at all — unless you
also enable signing, in which case supply the AWS signing keys:

```elixir
# only needed with sign?: true
%{
  aws_access_key_id: System.fetch_env!("AMAZON_SP_API_AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.fetch_env!("AMAZON_SP_API_AWS_SECRET_ACCESS_KEY")
}
```

## Building Requests

### `ReqAmazon.SpApi.Client.new/1`

Use `Client.new/1` when you want a ready-to-call `Req.Request` with the SP-API plugin attached:

```elixir
req =
  ReqAmazon.SpApi.Client.new(
    region: :na,
    credentials: %{
      client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
      client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET"),
      refresh_token: System.fetch_env!("AMAZON_SP_API_REFRESH_TOKEN")
    }
  )
```

Config options: `:region` (`:na` | `:eu` | `:fe`), `:endpoint`, `:aws_region`,
`:user_agent`, `:sign?` (default `false`), `:sandbox`. To sign with AWS SigV4,
pass `sign?: true` and add `aws_access_key_id`/`aws_secret_access_key` to the
credentials.

### `ReqAmazon.SpApi.attach/2`

Use `attach/2` when you already have a `Req` request and want to add the SP-API transport behavior yourself:

```elixir
req =
  Req.new(base_url: "https://sellingpartnerapi-na.amazon.com")
  |> ReqAmazon.SpApi.attach(credentials: %{...})
```

`attach/2` is the lower-level building block. `Client.new/1` is the convenience wrapper around it.

### Response Shape

Every operation returns `{:ok, %ReqAmazon.SpApi.Response{}}` on success or
`{:error, %ReqAmazon.SpApi.Error{}}` on failure.

```elixir
{:ok, %ReqAmazon.SpApi.Response{
  body: body,             # decoded response, with Amazon's `payload` envelope stripped
  status: 200,
  headers: headers,
  next_token: next_token, # pagination token, normalized across Amazon's casing/nesting (nil when no next page)
  rate_limit: rate_limit, # per-operation rate from `x-amzn-RateLimit-Limit` (nil when Amazon omits it)
  request_id: request_id  # `x-amzn-RequestId`, the value to quote in support cases
}} = ReqAmazon.SpApi.Orders.list_orders(req, marketplace_ids: ["ATVPDKIKX0DER"])
```

`body` is never transformed beyond stripping the `payload` envelope; `next_token`,
`rate_limit`, and `request_id` are normalized metadata Amazon returns but that
callers would otherwise have to recover by hand. To page through results, follow
`next_token` until it is `nil`:

```elixir
def stream_orders(req, opts) do
  case ReqAmazon.SpApi.Orders.list_orders(req, opts) do
    {:ok, %{next_token: nil} = response} -> {:ok, response.body}
    {:ok, %{next_token: token} = response} -> # ... fetch next page with next_token: token
    {:error, error} -> {:error, error}
  end
end
```

The same metadata is preserved on failures: a throttled `Error` carries
`:status`, `:request_id`, `:retry_after`, and `:rate_limit`, so callers can back
off intelligently on `429`.

The streaming download helpers (`Reports.stream_report_document/4`,
`Reports.download_report_document/3`) and the Product Type Definitions
linked-schema fetchers operate on temporary, non-SP-API URLs and therefore return
the raw `Req.Response`/decoded body rather than a `Response` struct.

### Rate Limiting And Retries

Requests use a rate-limit-aware `:retry` policy by default. It behaves like Req's
`:transient` (retrying `408/429/500/502/503/504` and transient transport errors)
with one SP-API-specific addition: SP-API reports per-operation throttling via the
`x-amzn-RateLimit-Limit` header (the token-bucket refill rate) rather than
`Retry-After`. On a throttled `429` it waits roughly one token refill (`1 / rate`
seconds, capped at 30s) instead of generic exponential backoff. A `429`/`503` that
*does* include `Retry-After` is honored. Pass your own `:retry` to override.

### Telemetry

Each SP-API operation emits a span:

- `[:req_amazon, :request, :start]` — measurements `%{system_time: ...}`
- `[:req_amazon, :request, :stop]` — measurements `%{duration: native}`; metadata
  includes `:status`, `:rate_limit`, `:request_id`
- `[:req_amazon, :request, :exception]` — when the request never completed
  (transport/timeout)

All events carry `%{method: method, path: path}`. Attach a handler to feed your
metrics/throttling dashboards:

```elixir
:telemetry.attach("req-amazon", [:req_amazon, :request, :stop], &MyApp.Metrics.handle/4, nil)
```

### Caller-Managed Access Tokens

If your application refreshes LWA tokens itself, pass the access token with
`:access_token`. With signing off (the default) no credentials are needed at all:

```elixir
req =
  ReqAmazon.SpApi.Client.new(
    region: :eu,
    access_token: token
  )
```

### Grantless Operations

Some SP-API operations (e.g. Notifications, some Data Kiosk calls) are
*grantless* — they authorize with a `client_credentials` token scoped to a role
rather than a seller's refresh token. Pass `:grantless_scope` and the library
mints, caches, and reuses the token for you:

```elixir
req =
  ReqAmazon.SpApi.Client.new(
    grantless_scope: "sellingpartnerapi::notifications",
    credentials: %{
      client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
      client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET")
    }
  )

ReqAmazon.SpApi.Notifications.get_destinations(req)
```

Grantless clients do not need a `:refresh_token`. If you already manage tokens
yourself, you can still pass `:access_token` directly instead.

You can also inject the header yourself before calling `attach/2`:

```elixir
req =
  Req.new(base_url: "https://sellingpartnerapi-na.amazon.com")
  |> Req.Request.put_header("x-amz-access-token", token)
  |> ReqAmazon.SpApi.attach(credentials: %{aws_access_key_id: "...", aws_secret_access_key: "..."})
```

### Endpoint And Region Overrides

Per Amazon's SP-API endpoint documentation, the standard regional hosts are:

- North America (`:na`): `https://sellingpartnerapi-na.amazon.com`, AWS region `us-east-1`
- Europe (`:eu`): `https://sellingpartnerapi-eu.amazon.com`, AWS region `eu-west-1`
- Far East (`:fe`): `https://sellingpartnerapi-fe.amazon.com`, AWS region `us-west-2`

Pass `region:` to `Client.new/1` and both the endpoint and (when signing) the
`aws_region` are resolved from this table. `:endpoint`/`:aws_region` override it.

## Wrapper Conventions

The public endpoint modules follow these conventions:

- Path params are positional function args.
- Optional query params are keyword opts.
- Request bodies are explicit map args.
- Elixir opts use `snake_case`.
- Modules convert Elixir opts to Amazon's exact path and query names internally.
- Current and legacy versions stay side by side when Amazon revs a family in a breaking way.
- Versioned file and module naming follow `orders_v2026_01_01.ex` -> `ReqAmazon.SpApi.OrdersV20260101`.
- Prefer date-based version suffixes when Amazon publishes dated versions.
- Keep older generic names such as `FinancesV2` only as compatibility aliases when needed.

## Versioning Policy

`req_amazon` keeps legacy and current wrappers side by side instead of breaking old callers by renaming the plain module in place.

Current examples:

- `ReqAmazon.SpApi.Orders` keeps the legacy Orders `v0` wrapper.
- `ReqAmazon.SpApi.OrdersV20260101` wraps the current Orders `v2026-01-01` API.
- `ReqAmazon.SpApi.Finances` keeps the legacy Finances `v0` wrapper.
- `ReqAmazon.SpApi.FinancesV20240619` wraps the current Finances `v2024-06-19` API.
- `ReqAmazon.SpApi.FinancesV2` remains as a compatibility alias for `ReqAmazon.SpApi.FinancesV20240619`.
- `ReqAmazon.SpApi.Pricing` keeps the legacy Product Pricing `v0` wrapper.
- `ReqAmazon.SpApi.PricingV20220501` wraps the current Product Pricing `v2022-05-01` API.

See [docs/api_version_matrix.md](docs/api_version_matrix.md) for the repo-wide matrix and [docs/sp_api_parity_checklist.md](docs/sp_api_parity_checklist.md) for the parity policy and audit notes from this pass.

## Examples

Reports:

```elixir
ReqAmazon.SpApi.Reports.get_report(req, "report-id")
ReqAmazon.SpApi.Reports.get_report_document(req, "report-document-id")
```

`get_report_document/2` returns Amazon's report document metadata, including
the temporary download URL. It does not download, persist, decompress, or parse
the report body. Use `stream_report_document/4` or `download_report_document/3`
when you want `Req` streaming via the `:into` callback or collectable. Large
report documents should be streamed instead of loaded into memory as one binary.

```elixir
ReqAmazon.SpApi.Reports.stream_report_document(
  req,
  "report-document-id",
  fn {:data, chunk}, {req, response} ->
    handle_chunk(chunk)
    {:cont, {req, response}}
  end
)
```

Listings Restrictions:

```elixir
ReqAmazon.SpApi.ListingsRestrictions.get_listings_restrictions(
  req,
  asin: "B000123456",
  seller_id: "SELLER1",
  marketplace_ids: ["ATVPDKIKX0DER"],
  product_type: "LUGGAGE"
)
```

Product Type Definitions linked schemas:

```elixir
{:ok, definition} =
  ReqAmazon.SpApi.ProductTypeDefinitions.get_definitions_product_type(
    req,
    "LUGGAGE",
    marketplace_ids: ["ATVPDKIKX0DER"]
  )

ReqAmazon.SpApi.ProductTypeDefinitions.fetch_schema(definition)
ReqAmazon.SpApi.ProductTypeDefinitions.fetch_meta_schema(definition)
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

Current Finances API:

```elixir
ReqAmazon.SpApi.FinancesV20240619.list_transactions(
  req,
  posted_after: "2026-03-01T00:00:00Z",
  marketplace_id: "ATVPDKIKX0DER",
  transaction_status: "RELEASED"
)
```

A+ Content / Brand Story:

```elixir
ReqAmazon.SpApi.APlusContent.search_content_documents(
  req,
  marketplace_id: "ATVPDKIKX0DER"
)
```

Brand Story content uses the same `ReqAmazon.SpApi.APlusContent` module. There
is no separate Brand Story API family in SP-API.

Typical lifecycle:

```elixir
marketplace_opts = [marketplace_id: "ATVPDKIKX0DER"]

payload = %{
  "contentDocument" => %{
    "name" => "Brand Story - Core Collection",
    "contentType" => "EMC",
    "locale" => "en-US",
    "contentModuleList" => []
  }
}

ReqAmazon.SpApi.APlusContent.validate_content_document_asin_relations(
  req,
  marketplace_opts,
  %{
    "asinSet" => ["B000123456"],
    "contentDocument" => payload["contentDocument"]
  }
)

ReqAmazon.SpApi.APlusContent.create_content_document(req, marketplace_opts, payload)

ReqAmazon.SpApi.APlusContent.post_content_document_asin_relations(
  req,
  "content-ref-key",
  marketplace_opts,
  %{"asinSet" => ["B000123456"]}
)

ReqAmazon.SpApi.APlusContent.post_content_document_approval_submission(
  req,
  "content-ref-key",
  marketplace_id: "ATVPDKIKX0DER"
)
```

If the content document contains images, use `ReqAmazon.SpApi.Uploads` first to
create upload destinations and then place the returned
`uploadDestinationId` values inside the A+ content payload before validation.

Notifications:

```elixir
grantless_req =
  ReqAmazon.SpApi.Client.new(
    grantless_scope: "sellingpartnerapi::notifications",
    credentials: %{
      client_id: System.fetch_env!("AMAZON_SP_API_CLIENT_ID"),
      client_secret: System.fetch_env!("AMAZON_SP_API_CLIENT_SECRET")
    }
  )

ReqAmazon.SpApi.Notifications.get_destinations(grantless_req)
ReqAmazon.SpApi.Notifications.get_subscription(
  grantless_req,
  "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
  payload_version: "2023-11-15"
)

ReqAmazon.SpApi.Notifications.send_test_notification(
  grantless_req,
  "DATA_KIOSK_QUERY_PROCESSING_FINISHED",
  %{"destinationId" => "destination-id"}
)
```

Sellers:

```elixir
ReqAmazon.SpApi.Sellers.get_marketplace_participations(req)
ReqAmazon.SpApi.Sellers.get_account(req)
```

`ReqAmazon.SpApi.Sellers.get_account/1` is documented by Amazon as EU-only.

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
