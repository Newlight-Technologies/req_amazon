# Changelog

## Unreleased

- Added `ReqAmazon.SpApi.OrdersV20260101` alongside the legacy `ReqAmazon.SpApi.Orders` v0 module.
- Added `ReqAmazon.SpApi.PricingV20220501` alongside the legacy `ReqAmazon.SpApi.Pricing` v0 module, while keeping backwards-compatible delegates for the current batch calls.
- Added caller-managed `:access_token` support for SP-API requests and documented the `attach/2` vs `Client.new/1` transport paths.
- Expanded `CustomerFeedback`, `Listings`, and `CatalogItems` coverage to better match the current SP-API surface.
- Added comprehensive A+ Content and Uploads request-construction coverage, and documented Brand Story as part of the A+ content-document API.
- Added request-construction coverage for Notifications, Data Kiosk, Sellers, and Finances v2024, expanded the current Transactions wrapper to support `transaction_status` without requiring `marketplace_id`, and standardized the current Finances module name on `ReqAmazon.SpApi.FinancesV20240619` while keeping `FinancesV2` as a compatibility alias.
- Added stronger transport and endpoint request-construction tests, including current Orders coverage.
- Added SP-API version matrix and parity checklist documentation.
- Prepared the repository for public consumption.
- Replaced Hex-oriented placeholder documentation with Git dependency usage.
- Added baseline public-repo metadata and local-tooling ignore rules.
