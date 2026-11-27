# Operation contracts — UC-10 Reconcile Offline Transactions

Signatures and result types follow `design/integrated-design-class-diagram.puml`. Error names follow `design/operation-error-catalogue.md`.

- **Business result:** `OfflineOperationResult` = `OfflineOperationSuccess` (returns the `OfflineTransaction` with its new status) or `OfflineOperationRejected(reason, invalidFields)`.
- **Technical failures** (`SaleRecordingUnavailable`, `StockServiceUnavailable`, `PersistenceFailed`) are reported separately from business results and never change the last confirmed state.
- **Signed-in user:** the user's ID is not an operation input. It comes from `CurrentUser.getUserId()` (D-CA2-20). `CurrentUser` provides identity only; the role checks still apply.
- **Status values:** `AwaitingReconciliation`, `Reconciled`, `ReferredToManager`, `Resolved`.
- **Referral reasons:** `DuplicateReference`, `ItemAlreadySold`, `ItemReserved`, `ItemUnknown`, `SaleRejected`.

## CO-1 enterOfflineTransaction(submissionId, offlineRef, saleDate, lines): OfflineOperationResult

| | |
|---|---|
| **Cross-references** | UC-10 steps 2–3, A1, A6, E1, E3; SC-11, SC-13; FR-13 |
| **Preconditions** | Caller is an authorised Market Coordinator (`requireCoordinatorRole`) |
| **Postconditions — new reference** | An `OfflineTransaction` was created with a new `entryId`, `submissionId`, `offlineRef`, `saleDate`, `recordedBy = CurrentUser.getUserId()` and `recordedAt = Clock.now()`; an `OfflineLine` (`itemCode`, `quantity`, `soldPrice`) was created for each line; `status = AwaitingReconciliation`; result `OfflineOperationSuccess` |
| **Postconditions — reference already used** | The `OfflineTransaction` was created as above; `status = ReferredToManager`; `referralReason = DuplicateReference`; `SaleRecordingPort` was not called; result `OfflineOperationSuccess` |
| **Postconditions — submissionId already stored** | Nothing was created; the existing entry is returned in `OfflineOperationSuccess` |
| **Business refusals** | `InvalidOfflineEntry` with `invalidFields` (missing reference or date, no lines, missing item code, quantity < 1, missing or negative price, date after `Clock.now()`); `UnauthorisedCoordinator`. Nothing is stored |
| **Technical failures** | `PersistenceFailed`: entry not reported as stored |

## CO-2 reconcile(entryId): OfflineOperationResult

| | |
|---|---|
| **Cross-references** | UC-10 steps 4–8, A2, A3, A4, E2, E3; SC-12, SC-14; FR-13, NFR-05 |
| **Preconditions** | Caller is an authorised Market Coordinator; an `OfflineTransaction` with `entryId` exists; its `status = AwaitingReconciliation` |
| **Postconditions — always (before the first sale attempt)** | If `tx.saleRequest` was empty, a `SaleRequest` was created with `idempotencyKey = entryId`, `processedBy = CurrentUser.getUserId()`, `channel = OfflineMarket`, `customerRef = null`, `saleDate = tx.saleDate`, `sourceRef = tx.offlineRef` and one `SaleRequestLine` per `OfflineLine`, and it was persisted on `tx`. On a retry the stored request was reused unchanged, so `processedBy` keeps its first value even if another authorised Market Coordinator retries |
| **Postconditions — sale already recorded** (`findRecordedResult` returned `Recorded(saleRef)`) | `tx.saleRef` = original `saleRef`; `tx.status = Reconciled`; no conflict check and no new sale |
| **Postconditions — clean and recorded** (`recordSale` returned `Recorded(saleRef)`) | Exactly one sale exists for the request; `tx.saleRef` = returned `saleRef`; `tx.status = Reconciled` |
| **Postconditions — duplicate or stock conflict** | `recordSale` was not called; no sale and no line was recorded; `tx.status = ReferredToManager`; `tx.referralReason` ∈ {`DuplicateReference`, `ItemAlreadySold`, `ItemReserved`, `ItemUnknown`} |
| **Postconditions — sale rejected** (`Rejected(reason)` from either port operation, including `IdempotencyKeyConflict`) | No sale was recorded; `tx.status = ReferredToManager`; `tx.referralReason = SaleRejected`; `tx.referralDetail` = the rejection reason |
| **Business refusals** | Entry not found; entry not `AwaitingReconciliation` (e.g. already reconciled); `UnauthorisedCoordinator`. No change, no sale |
| **Technical failures** | `SaleRecordingUnavailable`, `StockServiceUnavailable`, `PersistenceFailed`: `tx` stays `AwaitingReconciliation` with its stored `saleRequest`; a retry reuses the same request and idempotency key |

## CO-3 resolve(entryId, decision: ResolutionDecision, note): OfflineOperationResult

| | |
|---|---|
| **Cross-references** | UC-10 A5, E3; SC-15; A-08, BR-05 |
| **Preconditions** | Caller is an authorised Manager (`requireManagerRole`); an `OfflineTransaction` with `entryId` exists; its `status = ReferredToManager`; `decision` ∈ {`Accepted`, `Adjusted`, `Rejected`, `FollowUpOutsideSystem`}; `note` is not blank |
| **Postconditions** | `tx.decision`, `tx.resolutionNote`, `tx.resolvedBy = CurrentUser.getUserId()` and `tx.resolvedAt = Clock.now()` were set; `tx.status = Resolved`; `SaleRecordingPort` was not called and no sale was recorded; result `OfflineOperationSuccess` |
| **Business refusals** | `UnauthorisedManager`; entry not found; entry not `ReferredToManager`; missing decision or blank note. Entry unchanged |
| **Technical failures** | `PersistenceFailed`: entry stays `ReferredToManager` |

## Status transitions

| From | Operation | Condition | To |
|---|---|---|---|
| — | enterOfflineTransaction | new reference | `AwaitingReconciliation` |
| — | enterOfflineTransaction | reference already used | `ReferredToManager` (`DuplicateReference`) |
| `AwaitingReconciliation` | reconcile | `Recorded(saleRef)` from recovery or recording | `Reconciled` |
| `AwaitingReconciliation` | reconcile | duplicate, stock conflict or `Rejected` | `ReferredToManager` |
| `AwaitingReconciliation` | reconcile | technical failure | `AwaitingReconciliation` (unchanged) |
| `ReferredToManager` | resolve | valid decision and note | `Resolved` |

Any other transition is refused. NFR-05 is met when no entry is `AwaitingReconciliation` or `ReferredToManager`.
