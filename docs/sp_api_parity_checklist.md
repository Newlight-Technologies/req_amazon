# SP-API Parity Checklist

Audit date: April 21, 2026

## Baseline

- Before this pass, `mix test` passed with `24` tests and `0` failures.
- Before this pass, `mix compile` succeeded.
- After this pass, `mix test` passes with `47` tests and `0` failures.
- After this pass, `mix compile` succeeds.

## Policy Decisions

- Keep legacy and current versions side by side instead of silently retargeting a plain module.
- Use explicit versioned module and file names for new splits.
- Keep the library transport-focused and version-aware.
- Do not add Daisy workflow logic or response reshaping business logic.

## Wrapper Conventions

- Path params are positional function args.
- Optional query params are keyword opts.
- Request bodies are explicit map args.
- Elixir opts use `snake_case`.
- Modules translate Elixir opts to Amazon's exact query names internally.
- Compatibility helpers are acceptable when Amazon collapses multiple legacy read endpoints into one current endpoint, as long as the wrapper still returns Amazon's response shape.

## Completed In This Pass

- [x] Added `ReqAmazon.SpApi.OrdersV20260101` alongside legacy `ReqAmazon.SpApi.Orders`.
- [x] Kept Orders `v0` intact for compatibility.
- [x] Added current Orders migration helpers for buyer and recipient access through `included_data`.
- [x] Confirmed shipment confirmation remains legacy-only for now because the current Orders `v2026-01-01` reference exposes `searchOrders` and `getOrder`.
- [x] Added Customer Feedback return topic and return trend endpoints.
- [x] Expanded Listings query option coverage, including validation preview params and current search filters.
- [x] Expanded Catalog Items query option coverage, including identifiers, seller scope, locale, keyword filters, and pagination.
- [x] Verified Product Type Definitions request option coverage and locked it in with tests.
- [x] Split Product Pricing into explicit legacy and current modules with backwards-compatible delegates.
- [x] Added transport-level coverage for caller-supplied access tokens, SigV4 credential scope, token injection, user-agent injection, and non-2xx wrapping.
- [x] Documented the side-by-side versioning policy, wrapper conventions, and module matrix.
- [x] Updated changelog discipline and bumped the library version to `0.2.0`.

## First Daisy Adoption Step

- Adopt `ReqAmazon.SpApi.OrdersV20260101` in one narrow Daisy call path first.
- Leave the existing Reports integration unchanged during the first rollout.
- Expand Daisy adoption after the new Orders module proves stable in production.

## Follow-Up Candidates

- Do a full Amazon-currentness audit for the non-priority API families listed in `docs/api_version_matrix.md`.
- Apply the explicit side-by-side module split pattern to future breaking Amazon revs instead of growing mixed-version modules.
