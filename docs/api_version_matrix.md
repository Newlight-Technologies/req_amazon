# SP-API Version Matrix

This matrix reflects the `req_amazon` codebase on April 21, 2026.

The high-priority families in this pass were spot-checked against Amazon's current public documentation:

- Orders
- Customer Feedback
- Listings
- Catalog Items
- Product Type Definitions

The remaining rows are a repo coverage inventory based on the version each module advertises locally.

## Policy

- Keep legacy and current API versions side by side.
- Use explicit versioned modules for new splits, for example `ReqAmazon.SpApi.OrdersV20260101`.
- Keep file naming aligned with module naming, for example `orders_v2026_01_01.ex`.

## Seller And Shared Modules

| Module | File | Amazon version(s) | Status |
| --- | --- | --- | --- |
| `ReqAmazon.SpApi.APlusContent` | `lib/req_amazon/sp_api/a_plus_content.ex` | `v2020-11-01` | Current wrapper |
| `ReqAmazon.SpApi.AppIntegrations` | `lib/req_amazon/sp_api/app_integrations.ex` | `v2024-04-01` | Current wrapper |
| `ReqAmazon.SpApi.ApplicationManagement` | `lib/req_amazon/sp_api/application_management.ex` | `v2023-11-30` | Current wrapper |
| `ReqAmazon.SpApi.Awd` | `lib/req_amazon/sp_api/awd.ex` | `v2024-05-09` | Current wrapper |
| `ReqAmazon.SpApi.CatalogItems` | `lib/req_amazon/sp_api/catalog_items.ex` | `v2022-04-01` | Current wrapper, expanded in this pass |
| `ReqAmazon.SpApi.CustomerFeedback` | `lib/req_amazon/sp_api/customer_feedback.ex` | `v2024-06-01` | Current wrapper, expanded in this pass |
| `ReqAmazon.SpApi.DataKiosk` | `lib/req_amazon/sp_api/data_kiosk.ex` | `v2023-11-15` | Current wrapper |
| `ReqAmazon.SpApi.EasyShip` | `lib/req_amazon/sp_api/easy_ship.ex` | `v2022-03-23` | Current wrapper |
| `ReqAmazon.SpApi.ExternalFulfillment` | `lib/req_amazon/sp_api/external_fulfillment.ex` | `v2024-09-11` | Current wrapper |
| `ReqAmazon.SpApi.FbaInboundEligibility` | `lib/req_amazon/sp_api/fba_inbound_eligibility.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.FbaInventory` | `lib/req_amazon/sp_api/fba_inventory.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Feeds` | `lib/req_amazon/sp_api/feeds.ex` | `v2021-06-30` | Current wrapper |
| `ReqAmazon.SpApi.Finances` | `lib/req_amazon/sp_api/finances.ex` | `v0` | Legacy wrapper kept for compatibility |
| `ReqAmazon.SpApi.FinancesV2` | `lib/req_amazon/sp_api/finances_v2.ex` | `v2024-06-19` | Current wrapper kept beside legacy |
| `ReqAmazon.SpApi.FulfillmentInbound` | `lib/req_amazon/sp_api/fulfillment_inbound.ex` | `v2024-03-20` | Current wrapper |
| `ReqAmazon.SpApi.FulfillmentOutbound` | `lib/req_amazon/sp_api/fulfillment_outbound.ex` | `v2020-07-01` | Current wrapper |
| `ReqAmazon.SpApi.Invoices` | `lib/req_amazon/sp_api/invoices.ex` | `v2024-06-19` | Current wrapper |
| `ReqAmazon.SpApi.Listings` | `lib/req_amazon/sp_api/listings.ex` | `v2021-08-01` | Current wrapper, expanded in this pass |
| `ReqAmazon.SpApi.MerchantFulfillment` | `lib/req_amazon/sp_api/merchant_fulfillment.ex` | `v0` | Legacy wrapper |
| `ReqAmazon.SpApi.Messaging` | `lib/req_amazon/sp_api/messaging.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Notifications` | `lib/req_amazon/sp_api/notifications.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Orders` | `lib/req_amazon/sp_api/orders.ex` | `v0` | Legacy wrapper kept for compatibility |
| `ReqAmazon.SpApi.OrdersV20260101` | `lib/req_amazon/sp_api/orders_v2026_01_01.ex` | `v2026-01-01` | Current wrapper added in this pass |
| `ReqAmazon.SpApi.Pricing` | `lib/req_amazon/sp_api/pricing.ex` | `v0`, `v2022-05-01` | Mixed historical module; future splits should prefer explicit side-by-side modules |
| `ReqAmazon.SpApi.ProductFees` | `lib/req_amazon/sp_api/product_fees.ex` | `v0` | Legacy wrapper |
| `ReqAmazon.SpApi.ProductTypeDefinitions` | `lib/req_amazon/sp_api/product_type_definitions.ex` | `v2020-09-01` | Current wrapper, verified in tests in this pass |
| `ReqAmazon.SpApi.Replenishment` | `lib/req_amazon/sp_api/replenishment.ex` | `v2022-11-07` | Current wrapper |
| `ReqAmazon.SpApi.Reports` | `lib/req_amazon/sp_api/reports.ex` | `v2021-06-30` | Current wrapper |
| `ReqAmazon.SpApi.Sales` | `lib/req_amazon/sp_api/sales.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.SellerWallet` | `lib/req_amazon/sp_api/seller_wallet.ex` | `v2024-03-01` | Current wrapper |
| `ReqAmazon.SpApi.Sellers` | `lib/req_amazon/sp_api/sellers.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Services` | `lib/req_amazon/sp_api/services.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.ShipmentInvoicing` | `lib/req_amazon/sp_api/shipment_invoicing.ex` | `v0` | Legacy wrapper |
| `ReqAmazon.SpApi.Shipping` | `lib/req_amazon/sp_api/shipping.ex` | `v2` | Current wrapper |
| `ReqAmazon.SpApi.Solicitations` | `lib/req_amazon/sp_api/solicitations.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.SupplySources` | `lib/req_amazon/sp_api/supply_sources.ex` | `v2020-07-01` | Current wrapper |
| `ReqAmazon.SpApi.Tokens` | `lib/req_amazon/sp_api/tokens.ex` | `v2021-03-01` | Current wrapper |
| `ReqAmazon.SpApi.Transfers` | `lib/req_amazon/sp_api/transfers.ex` | `v2024-06-01` | Current wrapper |
| `ReqAmazon.SpApi.Uploads` | `lib/req_amazon/sp_api/uploads.ex` | `v2020-11-01` | Current wrapper |
| `ReqAmazon.SpApi.Vehicles` | `lib/req_amazon/sp_api/vehicles.ex` | `v2024-11-01` | Current wrapper |

## Vendor Modules

| Module | File | Amazon version(s) | Status |
| --- | --- | --- | --- |
| `ReqAmazon.SpApi.Vendor.DirectFulfillment.Inventory` | `lib/req_amazon/sp_api/vendor/direct_fulfillment/inventory.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.DirectFulfillment.Orders` | `lib/req_amazon/sp_api/vendor/direct_fulfillment/orders.ex` | `v2021-12-28` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.DirectFulfillment.Payments` | `lib/req_amazon/sp_api/vendor/direct_fulfillment/payments.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.DirectFulfillment.Shipping` | `lib/req_amazon/sp_api/vendor/direct_fulfillment/shipping.ex` | `v2021-12-28` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.DirectFulfillment.TransactionStatus` | `lib/req_amazon/sp_api/vendor/direct_fulfillment/transaction_status.ex` | `v2021-12-28` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.Invoices` | `lib/req_amazon/sp_api/vendor/invoices.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.Orders` | `lib/req_amazon/sp_api/vendor/orders.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.Shipments` | `lib/req_amazon/sp_api/vendor/shipments.ex` | `v1` | Current wrapper |
| `ReqAmazon.SpApi.Vendor.TransactionStatus` | `lib/req_amazon/sp_api/vendor/transaction_status.ex` | `v1` | Current wrapper |
