# Shared Contract Test Plan

## 1. StockAvailabilityPort contract tests

Run the same tests against every fake or implementation of `StockAvailabilityPort`.

| Test ID | Given | When | Expected result |
|---|---|---|---|
| STOCK-01 | An existing item is Available | `getStatus(itemCode)` | Returns `Available`. |
| STOCK-02 | An existing item is Reserved | `getStatus(itemCode)` | Returns `Reserved`. |
| STOCK-03 | An existing item is Sold | `getStatus(itemCode)` | Returns `Sold`. |
| STOCK-04 | An unknown item code is supplied | `getStatus(itemCode)` | Returns `Unknown`; it must not be treated as Available. |
| STOCK-05 | An item is Available | `reserveIfAvailable(itemCode)` | Changes status to Reserved and returns `Updated(Reserved)`. |
| STOCK-06 | An item is Reserved or Sold | `reserveIfAvailable(itemCode)` | Returns `Rejected(ItemUnavailable)`; status is unchanged. |
| STOCK-07 | An item is Available | `sellAllIfAvailable([itemCode], key)` | Changes status to Sold and returns `Updated(Sold)`. |
| STOCK-08 | One item in a multi-item request is not Available | `sellAllIfAvailable(stockLines, key)` | Rejects the whole request; no item in the request changes status. |
| STOCK-09 | An item is Reserved | `releaseIfReserved(itemCode)` | Changes status to Available only when release is permitted by the reservation rules. |
| STOCK-10 | An item is Sold or Unknown | `releaseIfReserved(itemCode)` | Does not change status; returns the agreed refusal. |
| STOCK-11 | Stock service is unavailable | Any operation requiring the provider | Returns/raises a technical failure; never reports Available or success. |
| STOCK-12 | A stock batch with an idempotency key has already succeeded | Repeat the same item list with the same key | Returns the original outcome; does not perform a second transition. |
| STOCK-13 | An idempotency key was used with a different item list | Repeat with the same key and different items | Rejects with `IdempotencyKeyConflict`; no stock changes. |

## 2. SaleRecordingPort contract tests

Run the same tests against `SaleService` and every fake used by a consuming slice.

| Test ID | Given | When | Expected result |
|---|---|---|---|
| SALE-01 | A valid request with one available item and maker attribution | `recordSale(request)` | Returns `Recorded(saleRef)`; item becomes Sold. |
| SALE-02 | A valid request with items from two makers | `recordSale(request)` | One sale is recorded; every line retains its maker attribution. |
| SALE-03 | Request has no lines | `recordSale(request)` | Returns `Rejected(NoLines)`; no sale or stock change. |
| SALE-04 | A line refers to an unknown item | `recordSale(request)` | Returns `Rejected(ItemNotFound)`; no sale or stock change. |
| SALE-05 | A line refers to a Sold or Reserved item | `recordSale(request)` | Returns `Rejected(ItemUnavailable)`; no sale or stock change. |
| SALE-06 | A line has invalid quantity or price | `recordSale(request)` | Returns the matching rejection; no sale or stock change. |
| SALE-07 | A line has no maker attribution | `recordSale(request)` | Returns `Rejected(MissingMakerAttribution)`; no sale or stock change. |
| SALE-08 | Processor is not authorised | `recordSale(request)` | Returns `Rejected(UnauthorisedProcessor)`; no sale or stock change. |
| SALE-09 | Same key and same payload were already recorded | Repeat `recordSale(request)` | Returns the original `Recorded(saleRef)`; no second sale. |
| SALE-10 | Same key is reused with a different payload | `recordSale(request)` | Returns `Rejected(IdempotencyKeyConflict)`; no new sale. |
| SALE-11 | One item in a multi-item request cannot be sold | `recordSale(request)` | Whole request is rejected; no line is sold. |
| SALE-12 | Persistence or stock update has a technical failure | `recordSale(request)` | No partial sale/stock change remains; technical failure is visible to the caller. |

## 3. Clock contract tests

| Test ID | Given | When | Expected result |
|---|---|---|---|
| CLOCK-01 | A fixed test time is configured | `now()` | Returns that exact time. |
| CLOCK-02 | The test time is advanced | `now()` | Returns the new configured time. |

Clock only supplies the current date and time. Working-day calculations belong to `ReservationPolicy`, not to Clock.

## 4. Cross-slice integration tests

| Test ID | Slice interaction | Expected result |
|---|---|---|
| INT-01 | Slice 1 reserves an Available item | Status becomes Reserved; Slice 3 and Slice 4 observe Reserved. |
| INT-02 | Slice 1 evaluates an expired reservation and releases it | Status becomes Available only when release is permitted; a later sale can proceed. |
| INT-03 | Slice 4 records a sale | Status becomes Sold; Slice 1 cannot reserve it and Slice 3 detects it as a conflict. |
| INT-04 | Slice 3 checks a clean offline transaction and calls SaleRecordingPort | It sends one complete request with `entryId` as idempotency key and receives `Recorded(saleRef)`. |
| INT-05 | Slice 3 receives `Recorded(saleRef)` | It stores the returned `saleRef` and changes the offline transaction to Reconciled. |
| INT-06 | Slice 3 receives `Rejected(reason)` | It changes the offline transaction to ReferredToManager; no Sale is recorded. |
| INT-07 | SaleRecordingPort times out | Slice 3 remains AwaitingReconciliation and retries with the same idempotency key. |
| INT-08 | An offline item is Reserved or Sold at pre-check | Slice 3 refers the whole transaction and does not call SaleRecordingPort. |
| INT-09 | A stock status changes after Slice 3's pre-check | SaleRecordingPort re-checks availability; the sale is rejected and no partial sale is committed. |
