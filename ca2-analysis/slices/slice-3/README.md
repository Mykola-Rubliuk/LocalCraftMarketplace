# Slice 3 — Reconcile Offline Transactions (UC-10)

**Working owner:** Bohdan Byrdin.

**Links:** US-09, FR-13, NFR-05, A-08, A-10, Q-08, Q-09, SC-11–SC-15, Issue #3, PB-06.

**Controller:** `OfflineReconciliationService`

**Shared interfaces required:** `SaleRecordingPort` (provided by Slice 4), `StockAvailabilityPort` (read-only, `getStatus`), `Clock` (`now`).

## 1. Purpose

This slice brings sales captured on the approved offline form during an internet outage into the system record, without losing or double-counting any of them. Clean offline transactions are recorded as sales through `SaleRecordingPort`; duplicates and conflicts are referred to the Manager and record no sale.

## 2. Artefacts

| Artefact | File |
|---|---|
| Use case | [use-case.md](use-case.md) |
| Gherkin | [features/offline-reconciliation.feature](features/offline-reconciliation.feature) |
| System sequence diagram | [ssd/ssd.puml](ssd/ssd.puml) |
| Operation contracts | [contracts/operation-contracts.md](contracts/operation-contracts.md) |
| CRC cards | [crc/crc.md](crc/crc.md) |
| GRASP justification | [grasp/grasp.md](grasp/grasp.md) |
| Sequence diagram (reconcile) | [sequence/sequence.puml](sequence/sequence.puml) |
| Design classes | [../../design/integrated-design-class-diagram.puml](../../design/integrated-design-class-diagram.puml) (Slice 3 package) |

## 3. Scope

### In scope

- Enter an offline transaction from a completed offline form after connectivity returns.
- Refuse incomplete or invalid entries.
- Detect repeated offline references (possible duplicates).
- Recover a sale already recorded for an entry before any new checks (safe retry).
- Check every line against stock status (Sold, Reserved, Unknown).
- Record a clean offline transaction as one sale through `SaleRecordingPort`.
- Refer duplicates, conflicts and rejected sales to the Manager.
- Record the Manager's decision and note.

### Out of scope

- The manual offline form itself (outside the system boundary).
- Offline reservations, orders and commission changes (A-10).
- Refunds and payment corrections (BR-05).
- Changing stock directly — only the sale-recording provider marks items Sold.
- Creating Sale or SaleLine objects — owned by Slice 4.

## 4. Provides / requires

- **Provides:** `OfflineReconciliationService` with `enterOfflineTransaction`, `reconcile(entryId)`, `resolve(entryId, decision, note)`.
- **Requires:** `OfflineTransactionRepository`, `StockAvailabilityPort.getStatus`, `SaleRecordingPort.recordSale` / `findRecordedResult`, `Clock.now`.
- **Fakes:** `InMemoryOfflineTransactionRepository`, `InMemoryStockAvailability`, `RecordingSaleRecorder` (stores requests by idempotency key, returns the stored `Recorded(saleRef)` for the same key and payload, `Rejected(IdempotencyKeyConflict)` for the same key with a different payload, marks items Sold in the fake stock, and can simulate a lost response or timeout).

## 5. SaleRequest built by Slice 3

| Field | Value |
|---|---|
| `idempotencyKey` | `entryId` |
| `processedBy` | Authorised Market Coordinator |
| `channel` | `OfflineMarket` |
| `customerRef` | `null` |
| `saleDate` | Offline transaction date |
| `sourceRef` | `offlineRef` |
| `lines` | One `SaleRequestLine` per `OfflineLine`: `itemCode`, `quantity`, `soldPrice`, optional `discountAmount` |

The request is created once, stored on the `OfflineTransaction` (`saleRequest`) **before the first sale-recording attempt**, and reused unchanged on every retry.

## 6. Sale recovery and idempotency

1. `reconcile(entryId)` loads the entry and checks it is `AwaitingReconciliation`.
2. It creates and persists the `SaleRequest` if none exists, or reuses the stored one.
3. It calls `findRecordedResult(request)` **before** duplicate and stock checks:
   - `Recorded(saleRef)` → the sale already exists; store the original `saleRef` and mark `Reconciled`.
   - `Rejected(IdempotencyKeyConflict)` → handled as a rejected request: refer as `SaleRejected` with the reason in `referralDetail`.
   - no result → continue with `ConflictChecker.check`.
4. If the check is clean, it calls `recordSale(request)`.
5. A technical failure at any step (`SaleRecordingUnavailable`, `StockServiceUnavailable`, `PersistenceFailed`) leaves the entry `AwaitingReconciliation`; the Coordinator retries with the same `SaleRequest` and key.

This prevents an offline sale that was already recorded (but whose response was lost) from being referred to the Manager on retry because its items now show as Sold.

| ID | Situation | Behaviour |
|---|---|---|
| R1 | Connection lost while entering forms | Entries already saved remain `AwaitingReconciliation` |
| R2 | Entry re-sent after a timeout | Same `submissionId` returns the existing entry; no false duplicate |
| R3 | Sale recorded but response lost | Retry finds `Recorded(saleRef)` through `findRecordedResult`; entry becomes `Reconciled`; no second sale |
| R4 | `recordSale` times out | Entry stays `AwaitingReconciliation`; retry reuses the same request |
| R5 | `findRecordedResult` fails | Technical failure; no checks, no sale call, no state change |
| R6 | Stock service does not answer | Technical failure; never treated as Available |
| R7 | `reconcile` repeated after success | Refused: entry is no longer awaiting reconciliation; no second sale |

## 7. Consistency with shared contracts

- Records are selected by `entryId`; `offlineRef` is used only for duplicate detection.
- Slice 3 reads stock with `getStatus` only and never changes stock.
- Only `Recorded(saleRef)` permits `Reconciled`.
- Business refusals are returned as `OfflineOperationRejected`; technical failures are reported separately (see `design/operation-error-catalogue.md`).
- Manager resolution never creates a sale.

## 8. Test plan

| Test | Expected result |
|---|---|
| SC-11 enter valid entry | `AwaitingReconciliation`; `entryId`, `offlineRef`, date, `recordedBy`, `recordedAt` stored |
| Incomplete form data | `OfflineOperationRejected(InvalidOfflineEntry)` with invalid fields; nothing stored |
| Same `submissionId` re-sent | Existing entry returned; no duplicate |
| SC-12 clean reconcile | One sale; `saleRef` stored; `Reconciled` |
| SC-13 reference entered again | New entry `ReferredToManager(DuplicateReference)`; still one sale |
| SC-14 item already sold | `ReferredToManager(ItemAlreadySold)`; no sale |
| Item reserved | `ReferredToManager(ItemReserved)`; no sale |
| Two lines, one sold | `ReferredToManager`; nothing sold |
| Sale recorded, response lost, retry | Original `saleRef` recovered; `Reconciled`; one sale only |
| `recordSale` times out | Still `AwaitingReconciliation`; `saleRequest` kept |
| Recovery lookup fails | Still `AwaitingReconciliation`; no sale call |
| `Rejected(IdempotencyKeyConflict)` | `ReferredToManager(SaleRejected)`; detail stored |
| Reconcile a reconciled entry | `OfflineOperationRejected`; one sale |
| SC-15 Manager rejects with note | `Resolved`; decision and note stored; no sale |
| Wrong role | `UnauthorisedCoordinator` / `UnauthorisedManager`; no change |
| NFR-05 full run | No `AwaitingReconciliation` or `ReferredToManager` entries remain |

**Demo route:** runner or Gherkin run on fakes — clean (OFF-03), duplicate (OFF-03 again), conflict (OFF-04 on sold CER-105), lost response and recovery, Manager resolution (OFF-04 rejected).

## 9. Assumptions

- Only sales are captured offline (A-10).
- The Market Coordinator enters and reconciles; the Manager resolves (A-08).
- Refunds and payment corrections are handled outside the system (BR-05).
- Retries are started manually by the Coordinator.
- Quantities follow the shared item-quantity rule (Q-02 / Q-SH-04).

## 10. Open questions

| ID | Question | Ask |
|---|---|---|
| Q-08 | How are offline references kept unique on paper forms? | Manager |
| Q-09 | May a Volunteer enter offline entries if the Manager assigns it? | Manager |
| Q-SH-04 | Are quantities above one valid for a single `itemCode`? | Group |
