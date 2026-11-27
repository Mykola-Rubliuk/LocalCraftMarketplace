# Slice 4 — CRC Cards

## SaleService

**Responsibilities**
- Implement `SaleRecordingPort.recordSale(SaleRequest)` and read-only `findRecordedResult(request)`.
- Validate request identity, processor authorisation and sale lines using `validateRequestAndIdempotency(request)`.
- Enforce idempotency by retrieving and checking previously recorded sale results.
- Resolve product and maker details through `ProductCatalogue.findItem()`.
- Check every item's stock status through `StockAvailabilityPort.getStatus()`.
- Obtain recording timestamps through `Clock.now()`.
- Coordinate the creation of Sale and SaleLine objects.
- Coordinate the all-or-nothing stock transition and sale persistence.
- Return `Recorded(saleRef)` or `Rejected(reason)` and report technical failures separately.

**Collaborators:** `SaleRecordingPort`, `Sale`, `SaleLine`, `SaleRepository`, `StockAvailabilityPort`, `ProductCatalogue`, `Clock`.

## Sale

**Responsibilities**
- Store saleRef, processedBy, optional customerRef and sourceRef, channel, saleDate, recordedAt and status.
- Initialise a Sale using `create(request, recordedAt)`.
- Own and maintain its collection of SaleLines.
- Add a SaleLine through `addLine(line)`.
- Calculate the sale total through `calculateTotal()` using the net amounts of its SaleLines.

**Collaborators:** `SaleLine`, `SaleService`, `SaleRepository`.

## SaleLine

**Responsibilities**
- Initialise a sale line through `create(item, maker, soldPrice, quantity, discountAmount)`.
- Retain the itemCode, product details and maker attribution.
- Store soldPrice, quantity and optional discountAmount.
- Calculate the line net amount through `calculateNetAmount()` using the agreed monetary rules.

**Collaborators:** `Sale`, `SaleService`, `Product`, `Maker`.

## ProductCatalogue

**Responsibilities**
- Find product/stock item information by itemCode.
- Provide maker attribution.
- Distinguish an unknown item from an item with missing maker attribution.

**Collaborators:** `SaleService`, `Product`, `Maker`.

## SaleRepository

**Responsibilities**
- Retrieve an existing sale result through `findByIdempotencyKey(key)`.
- Persist the Sale aggregate and its SaleLines through `persist(sale, record: IdempotencyRecord)`.
- Retain the idempotency key and sufficient request information to identify repeated or conflicting requests.
- Preserve the original recorded result for safe retries.
- Participate in the atomic consistency boundary between sale persistence and stock updates.

**Collaborators:** `SaleService`, `Sale`, `SaleLine`.

## StockAvailabilityPort (shared)

**Responsibilities**
- Read stock availability through `getStatus(itemCode)`.
- Report `Available`, `Reserved`, `Sold` or `Unknown`.
- Re-check availability before performing a stock transition.
- Atomically sell all requested stock lines through `sellAllIfAvailable(stockLines, idempotencyKey)`.
- Honour the idempotency key when repeating a stock operation.
- Return the documented stock update, refusal or technical failure outcomes.
- Ensure no partial stock transition occurs when any requested line fails.

**Collaborators:** `SaleService`; Slice 1 and Slice 3 also consume the shared port.

## Clock (shared)

**Responsibilities**
- Provide the current date and time through `now()`.
- Supply the recordedAt timestamp.
- Supply the date used as the default in-store saleDate when no explicit sale date is provided.

**Collaborators:** `SaleService`.

## SaleRecordingPort (shared)

**Responsibilities**
- Define the shared `recordSale(request: SaleRequest)` and `findRecordedResult(request: SaleRequest)` operations.
- Provide a consistent sale-recording boundary for in-store and offline sales.
- Define the expected sale-recording outcomes.
- Require idempotent and all-or-nothing sale-recording behaviour.
- Isolate consumers from the internal sale-recording implementation.

**Collaborators:** `SaleService`, `OfflineReconciliationService`.
