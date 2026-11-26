# Shared Interface Catalogue

**Status:** Proposed contracts for group review. These definitions are the common reference for Slice 1, Slice 2, Slice 3 and Slice 4. They are design contracts, not evidence of a completed implementation.

## 1. StockAvailabilityPort

**Provider:** Shared stock capability  
**Consumers:** Slice 1 — Reservation; Slice 3 — Offline Reconciliation; Slice 4 — Customer Sale

**Purpose:** Provide one consistent way to query and change the availability of a stock item. No slice should maintain a separate interpretation of stock status.

### Stock status

`StockStatus = Available | Reserved | Sold | Unknown`

`Unknown` means that the supplied `itemCode` does not identify a stock item.

### Operations

| Operation | Purpose | Expected result |
|---|---|---|
| `getStatus(itemCode)` | Read the current stock status. | `StockStatus` |
| `reserveIfAvailable(itemCode)` | Atomically change `Available` to `Reserved`. | `Updated(Reserved)` or `Rejected(ItemNotFound / ItemUnavailable)` |
| `sellAllIfAvailable(stockLines, idempotencyKey)` | Atomically change the requested stock quantities from `Available` to `Sold`. Each stock line contains `itemCode` and `quantity`. If any line cannot be sold, none are changed. Repeating the same key with the same stock lines returns the original outcome; reusing the key with different stock lines is rejected. | `Updated(Sold)` or `Rejected(reason, itemCode)` |
| `releaseIfReserved(itemCode)` | Change `Reserved` to `Available` when the owning reservation has expired and no other commitment applies. | `Updated(Available)` or `Rejected(ItemNotFound / InvalidStockTransition)` |

Technical failure to access or update stock is reported as a technical failure, not as `Available` or a normal business refusal.

### Consumer rules

- Slice 1 uses `getStatus`, `reserveIfAvailable` and `releaseIfReserved`.
- Slice 3 uses `getStatus` for conflict checking only. It must not change stock directly.
- Slice 4 uses `getStatus` for validation and `sellAllIfAvailable` as part of sale recording.
- Slice 3 must not mark items Sold itself. Sale recording owns that change.
- `sellAllIfAvailable` must re-check availability when it performs the change. A previous `getStatus` result is not a guarantee that the item remains available.
- The `itemCode` / quantity relationship remains subject to Q-02 and Q-SH-04. Until clarified, examples treat each listed `itemCode` as one stock unit.

### Important consistency constraint

The sale requires all-or-nothing behaviour across sale persistence and stock changes. `sellAllIfAvailable` guarantees an all-or-nothing stock transition for the supplied item codes. The group must still agree how that stock operation and `SaleRepository` persistence share a transaction or use a safe prepare/commit/compensation mechanism. The interface alone does not prove cross-store atomicity.

## 2. SaleRecordingPort

**Provider:** Slice 4 — Process a Customer Sale (UC-01)  
**Implementation:** `SaleService`  
**Consumer:** Slice 3 — Reconcile Offline Transactions (UC-10), and any other approved sale-recording workflow

**Purpose:** Provide one entry point for recording a sale. Consumers must not create `Sale` / `SaleLine` records or update stock directly.

### Operation

`recordSale(request: SaleRequest): SaleRecordingResult`

### SaleRequest

| Field | Required? | Meaning |
|---|---|---|
| `idempotencyKey` | Yes | Stable key for this sale request. Slice 3 uses the offline transaction's `entryId`. |
| `processedBy` | Yes | Identifier of the authorised person submitting the sale. |
| `channel` | Yes | `InStore` or `OfflineMarket`. |
| `customerRef` | No | Customer reference, if known. |
| `saleDate` | No for in-store; required for offline | Date the customer actually made the purchase. If omitted for an in-store sale, Slice 4 uses `Clock.now()`. |
| `sourceRef` | No | External source reference, such as the offline form's `offlineRef`. |
| `lines` | Yes, at least one | Sale lines to record. |

Each sale line contains:

- `itemCode`
- `quantity`
- `soldPrice`
- `discountAmount` (optional; detailed discount rules remain subject to Q-06)

The quantity and item identity rule remains subject to Q-02 / Q-SH-04. Slice 3 must send the quantity written on the offline form; the group must confirm whether quantities above one are valid for a single `itemCode`.

### Result

`SaleRecordingResult` has two expected business outcomes:

- `Recorded(saleRef)` — the sale has been recorded and stock has been updated.
- `Rejected(reason)` — the request was refused and no sale or stock change was committed.

Technical failures, such as unavailable persistence or stock services, are reported as technical failures. A consumer must not mark an offline transaction as Reconciled after a technical failure.

### Idempotency

- Repeating the same request with the same `idempotencyKey` and same payload returns the original `Recorded(saleRef)` result. It must not create another Sale.
- Reusing the same key with a different payload is rejected with `IdempotencyKeyConflict`.
- Slice 3 uses `entryId` as the key.
- Ordinary in-store callers must also supply a stable key so a retry after an unknown outcome cannot create a duplicate sale.

### Provider responsibilities

Slice 4 is responsible for validation, maker attribution, availability checking, sale creation, stock updates, idempotency and the sale result.

### Consumer responsibilities

Slice 3 must:

- Complete its own duplicate-reference and stock-conflict checks first.
- Send one complete `SaleRequest` for the whole offline transaction.
- Use `entryId` as `idempotencyKey`.
- Use `channel = OfflineMarket`, the form date as `saleDate`, the coordinator as `processedBy`, and `offlineRef` as `sourceRef`.
- Treat `Recorded(saleRef)` as the only confirmation that allows the offline record to become Reconciled.
- Treat `Rejected(reason)` as a business conflict requiring referral.
- Leave the record `AwaitingReconciliation` after a technical failure so it can be retried with the same key.

## 3. Clock

**Provider:** Shared time abstraction  
**Consumers:** Slice 1, Slice 2, Slice 3 and Slice 4

### Operation

`now(): DateTime`

Clock supplies the current date and time only. Reservation working-day calculations belong to `ReservationPolicy`, using an agreed working-day calendar. The calendar and expiry policy remain open under Q-01 and Q-SH-03.

- Slice 1 uses `now()` to evaluate reservation expiry.
- Slice 2 uses `now()` for an order line's `lastChangedAt`.
- Slice 3 uses `now()` for `recordedAt` and manager-resolution timestamps.
- Slice 4 uses `now()` for `recordedAt` and as the default in-store `saleDate`.

## 4. Integration rules

1. Shared operation names, request fields, status values and result names must be copied exactly into each slice's contracts and diagrams.
2. A fake implementation must follow the same behaviour as the shared contract.
3. Consumers depend on the port, not on another slice's internal service, entity or repository.
4. Only Slice 4 records Sale and SaleLine data.
5. Only the stock provider performs stock state transitions.
6. Changes to a shared contract require review by every affected slice owner and an update to the shared contract test suite.
