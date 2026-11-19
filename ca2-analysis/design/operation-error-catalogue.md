# Shared Operation and Error Catalogue

**Purpose:** Keep expected business refusals and technical failures consistent across Slice 1, Slice 3 and Slice 4.

An error name may be reused only when it has the same meaning. Context-specific referral reasons are not interchangeable with operation errors.

## 1. Shared stock outcomes

| Name | Meaning | Used by | Expected handling |
|---|---|---|---|
| `ItemNotFound` | The `itemCode` does not identify a stock item. | Slice 1, Slice 3 conflict check, Slice 4 | Do not change stock. Reservation/sale request is refused; Slice 3 refers the offline record as `ItemUnknown`. |
| `ItemUnavailable` | The item exists but cannot make the requested transition from its current status. | Slice 1, Slice 4 | Refuse the requested reservation or sale; leave stock unchanged. |
| `InvalidStockTransition` | The requested transition is not valid for the current status or commitment. | Slice 1 stock release and shared stock operations | Do not change stock; caller handles the refusal. |
| `StockUpdateFailed` | A stock state change could not be completed because of a technical or persistence failure. | Slice 1, Slice 4 | Treat as a technical failure. Do not report success; preserve or restore the original state. |
| `StockServiceUnavailable` | The stock capability could not be reached or did not return a reliable result. | Slice 1, Slice 3, Slice 4 | Do not assume the item is Available. Leave the caller's workflow state unchanged or return a technical failure. |

## 2. Slice 1 — Reservation

| Name | Meaning | Expected handling |
|---|---|---|
| `MissingDetails` | Customer reference or required reservation conditions are missing. | Reject before creating a reservation or changing stock. |
| `ConflictingReservation` | An active reservation already exists for the item. | Reject; do not create another reservation. |
| `ReservationPolicyUnavailable` | The agreed expiry cannot be calculated because the policy/calendar is missing or unavailable. | Reject; do not create a reservation or change stock. |
| `PersistenceFailed` | Reservation data could not be stored or updated. | Technical failure; reservation and stock must remain consistent. |

`ItemNotFound`, `ItemUnavailable`, `InvalidStockTransition`, `StockUpdateFailed` and `StockServiceUnavailable` are shared stock outcomes above; do not define different meanings for them in Slice 1.

## 3. Slice 3 — Offline Reconciliation

### Referral reasons

These are stored on an `OfflineTransaction` when it cannot safely be reconciled. They are not all errors returned by a port.

| Referral reason | Meaning | Expected handling |
|---|---|---|
| `DuplicateReference` | Another stored offline entry already uses the same `offlineRef`. | Store the new entry as `ReferredToManager`; do not call SaleRecordingPort. |
| `ItemAlreadySold` | A line refers to an item whose stock status is `Sold`. | Refer the whole offline transaction; record no Sale. |
| `ItemReserved` | A line refers to an item whose stock status is `Reserved`. | Refer the whole offline transaction; record no Sale. |
| `ItemUnknown` | A line refers to an unknown item (`Unknown` / `ItemNotFound`). | Refer the whole offline transaction; record no Sale. |
| `SaleRejected` | SaleRecordingPort returned `Rejected(reason)` after the pre-check. | Refer the whole offline transaction and retain the underlying sale rejection reason. |

### Entry and access refusals

| Name | Meaning | Expected handling |
|---|---|---|
| `InvalidOfflineEntry` | Required offline form data is missing or invalid. | Refuse entry; store nothing and list the invalid fields. |
| `UnauthorisedCoordinator` | User is not authorised to enter or reconcile offline transactions. | Refuse the operation; do not change the transaction. |
| `UnauthorisedManager` | User is not authorised to resolve a referred transaction. | Refuse the operation; leave it `ReferredToManager`. |
| `AmbiguousOfflineReference` | An operation selected a repeated `offlineRef` where more than one entry matches. | Do not select an arbitrary record. Use `entryId` to identify the intended entry. |

### Technical failures

| Name | Meaning | Expected handling |
|---|---|---|
| `SaleRecordingUnavailable` | SaleRecordingPort did not return a reliable result because of a technical failure or timeout. | Keep the offline record `AwaitingReconciliation`; retry with the same `entryId` idempotency key. |
| `PersistenceFailed` | An offline transaction could not be stored or updated. | Do not report the state transition as successful. Preserve the last confirmed state. |

## 4. Slice 4 — Customer Sale

| Name | Meaning | Expected handling |
|---|---|---|
| `NoLines` | The sale request contains no sale lines. | Reject before creating a Sale or changing stock. |
| `InvalidQuantity` | Quantity is zero, negative or violates the agreed item-quantity rule. | Reject; create no Sale and change no stock. |
| `InvalidPrice` | Selling price is missing, negative or otherwise invalid. | Reject; create no Sale and change no stock. |
| `InvalidDiscount` | Discount violates the agreed discount rules. | Reject; create no Sale and change no stock. |
| `MissingMakerAttribution` | Product/stock data has no valid maker attribution. | Reject; create no Sale or SaleLine. |
| `UnauthorisedProcessor` | The submitting person is not authorised to record sales. | Reject before recording or changing stock. |
| `IdempotencyKeyConflict` | An existing idempotency key is reused with a different request payload. | Reject; do not create another Sale or change stock. |
| `PersistenceFailed` | Sale or SaleLine persistence failed. | Technical failure; no partial sale or stock changes may remain. |

`ItemNotFound` and `ItemUnavailable` are shared stock outcomes and must use the definitions in Section 1.


## 5. Naming rules

- Use `Recorded(saleRef)` / `Rejected(reason)` for SaleRecordingPort.
- Use `ItemNotFound` and `ItemUnavailable` consistently across stock consumers.
- Use `SaleRejected` only as Slice 3's referral reason when SaleRecordingPort rejects a request.
- Do not use a technical failure such as timeout as an ordinary business referral reason.
