# Slice 4 — Operation Contract

## OC-4.1 `recordSale(request: SaleRequest): SaleRecordingResult`

This is the operation provided by `SaleRecordingPort`. `SaleService` implements it.

### SaleRequest

| Field | Required? | Meaning |
|---|---|---|
| `idempotencyKey` | Yes | Stable key for this request. Required for safe retries. |
| `processedBy` | Yes | Identifier of the authorised Shop Volunteer or Market Coordinator. |
| `channel` | Yes | `InStore` or `OfflineMarket`. |
| `customerRef` | No | Customer reference, if known. |
| `saleDate` | Conditional | Actual purchase date. Required for offline transactions; defaults to `Clock.now()` for an in-store sale. |
| `sourceRef` | No | External source reference, such as an offline form reference. |
| `lines` | Yes | One or more sale lines. |

Each line contains `itemCode`, `quantity`, `soldPrice` and optional `discountAmount`.

### Preconditions
- `idempotencyKey` and `processedBy` are supplied.
- The processor is authorised to record sales.
- `lines` contains at least one line.
- Each item code resolves through ProductCatalogue.
- Every item has maker attribution.
- Quantity, selling price and any discount satisfy the agreed validation rules.
- Every item is Available. Reserved items are not sellable unless Q-SH-01 is later resolved with an explicit contract change.
- The request date is valid; offline callers supply the actual form date.
- A repeated idempotency key is associated with the same request payload.

### Success postconditions
- One Sale is recorded with unique `saleRef` and status Completed.
- One SaleLine is recorded for each requested line.
- Each SaleLine retains product/stock item and maker attribution.
- Each SaleLine stores soldPrice, quantity and any applicable discount.
- All requested stock items are changed from Available to Sold.
- Sale persistence and stock changes are committed consistently.
- The result is `Recorded(saleRef)`.

### Expected business refusals
- `NoLines`
- `UnauthorisedProcessor`
- `ItemNotFound`
- `ItemUnavailable`
- `MissingMakerAttribution`
- `InvalidQuantity`
- `InvalidPrice`
- `InvalidDiscount`
- `IdempotencyKeyConflict`

The result is `Rejected(reason)`. No Sale/SaleLine or stock change is committed.

### Idempotency
- Same key + same payload: return the original result and do not create a second Sale.
- Same key + different payload: return `Rejected(IdempotencyKeyConflict)`.
- Slice 3 uses its `entryId` as the key. An ordinary in-store caller must also provide a stable key.

### Technical failure guarantee
A persistence or stock technical failure must not leave partial Sale/SaleLine records or partial stock changes. Technical failures such as `PersistenceFailed`, `StockUpdateFailed` or `StockServiceUnavailable` are not normal business refusals. The provider must not return `Recorded` until the sale and stock changes are committed consistently.

**Integration issue:** `StockAvailabilityPort.sellAllIfAvailable` can make the stock transition atomic for all lines, but this alone does not prove atomicity across stock persistence and `SaleRepository`. The group must agree whether both share a transaction or use a safe prepare/commit/compensation mechanism.

## Shared contract references

- Request, result and shared ports: `design/shared-interface-catalogue.md`.
- Error definitions: `design/operation-error-catalogue.md`.
- Required fake/implementation tests: `design/shared-contract-test-plan.md`.
- Open business rules: Q-06, Q-SH-01, Q-SH-02, Q-02 / Q-SH-04 and Q-SH-06.
