# Slice 4 — CRC Cards

## SaleService

**Responsibilities**
- Implement `SaleRecordingPort.recordSale(SaleRequest)`.
- Validate request identity, processor and sale lines.
- Enforce idempotency.
- Resolve product and maker details through ProductCatalogue.
- Check every item's stock status.
- Coordinate Sale/SaleLine creation and the all-or-nothing stock transition.
- Return `Recorded(saleRef)` or `Rejected(reason)`.

**Collaborators:** `Sale`, `SaleLine`, `SaleRepository`, `StockAvailabilityPort`, `ProductCatalogue`, `Clock`.

## Sale

**Responsibilities**
- Store saleRef, processor, optional customer reference, channel, saleDate, recordedAt and status.
- Contain SaleLines.
- Calculate the sale total from its lines using the agreed monetary rules.

**Collaborators:** `SaleLine`, `SaleService`, `SaleRepository`.

## SaleLine

**Responsibilities**
- Store itemCode / stock item reference, maker attribution, soldPrice, quantity and optional discount.
- Calculate the line net amount under the agreed discount rules.

**Collaborators:** `Sale`, `Product`, `Maker`.

## ProductCatalogue

**Responsibilities**
- Find product/stock item information by itemCode.
- Provide maker attribution.
- Distinguish an unknown item from an item with missing maker attribution.

**Collaborators:** `SaleService`, `Product`, `Maker`.

## SaleRepository

**Responsibilities**
- Persist and retrieve the Sale aggregate and its SaleLines.
- Store the idempotency key and original result so retries cannot create a duplicate sale.
- Participate in the agreed atomic commit/compensation design with stock changes.

**Collaborators:** `SaleService`, `Sale`, `SaleLine`.

## StockAvailabilityPort (shared)

**Responsibilities**
- Read status through `getStatus(itemCode)`.
- Atomically sell all requested item codes through `sellAllIfAvailable(stockLines, idempotencyKey)`.
- Return shared status and refusal values.

**Collaborators:** `SaleService`; Slice 1 and Slice 3 also consume the shared port.

## Clock (shared)

**Responsibilities:** Provide `now()` for recordedAt and the default in-store saleDate.

**Collaborators:** `SaleService`.
