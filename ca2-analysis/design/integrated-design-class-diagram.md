# Integrated Design Class Diagram

**Scope:** Slices 1–4: Manage Reservation (UC-02), Manage Customer Order (UC-04), Reconcile Offline Transactions (UC-10), and Process a Customer Sale (UC-01).

**Diagram source:** [`integrated-design-class-diagram.puml`](integrated-design-class-diagram.puml)

The diagram combines the four behavioural designs, their controllers, domain objects, repositories and shared contracts. Slice 2 uses the proposed CurrentUser collaborator documented in D-CA2-18; this does not imply group approval or a shared identity policy.

## Integration structure

| Shared abstraction | Provider / implementation | Consumers | Responsibility |
|---|---|---|---|
| `StockAvailabilityPort` | Shared stock capability | Slice 1, Slice 3 and Slice 4 | Provide a common stock-status vocabulary and controlled stock transitions. |
| `SaleRecordingPort` | `SaleService` in Slice 4 | Slice 3 and in-store sale callers | Provide one boundary for recording and recovering sales. |
| `CurrentUser` (proposed for Slice 2) | Signed-in user context | Slice 2 | Provide the volunteer identifier. |
| `Clock` | Shared time abstraction | Slices 1–4 | Supply the current date and time through `now()`. |

Concrete stock and clock implementations are outside the abstraction level of this design diagram.

## How the four slices collaborate

1. **Slice 1 — Manage Reservation:** `ReservationService` validates reservation details, reads stock availability through `StockAvailabilityPort`, and checks existing reservations through `ReservationRepository`. It obtains the current time from `Clock` and delegates expiry calculation to `ReservationPolicy`. It creates an Active `Reservation` and requests `reserveIfAvailable`. Reservation persistence and stock changes must be consistent. During expiry evaluation, eligible reservations become Expired and `releaseIfReserved` releases the associated stock only when no other commitment applies.
2. **Slice 2 — Manage Customer Order:** `OrderFulfilmentService` coordinates view and line changes, using `CustomerOrderRepository`, `CurrentUser` (proposed) and `Clock`. `OrderLine` owns valid transitions; `CustomerOrder` derives its overall status and is saved with the changed line. Collection does not create a sale.
3. **Slice 3 — Reconcile Offline Transactions:** `OfflineReconciliationService` records offline entries through `OfflineTransactionRepository`. Each entry has a unique internal `entryId`; `offlineRef` is retained for duplicate-reference checks and `submissionId` supports safe resubmission. Before checking conflicts, the service persists and reuses the original request and attempts read-only recovery via `findRecordedResult`. `ConflictChecker` checks duplicate references and reads stock through `StockAvailabilityPort.getStatus`. Duplicate or conflicting transactions are referred to the Manager without recording a new sale. A clean transaction is submitted as one complete `SaleRequest` to `SaleRecordingPort`, using `entryId` as its idempotency key. A confirmed `Recorded(saleRef)` result permits the transaction to become Reconciled. Manager resolution records the decision and note without creating a sale.
4. **Slice 4 — Process a Customer Sale:** `SaleService` implements `SaleRecordingPort`. It validates the request and idempotency key, obtains product and maker details from `ProductCatalogue`, and checks availability through `StockAvailabilityPort`. It creates `Sale` and `SaleLine` data, retaining product and maker attribution, quantity, selling price and any applicable discount. `sellAllIfAvailable` performs the all-or-nothing stock transition, and `SaleRepository` persists the sale and its idempotency result. `Recorded(saleRef)` is returned only after the sale and stock changes have been committed consistently.

## Operation alignment

The integrated model uses the operation names and signatures defined by the shared contracts and represented in the class diagram:

| Class / interface | Operations |
|---|---|
| `StockAvailabilityPort` | `getStatus(itemCode)`, `reserveIfAvailable(itemCode)`, `releaseIfReserved(itemCode)`, `sellAllIfAvailable(stockLines, idempotencyKey)` |
| `SaleRecordingPort` | `recordSale(request: SaleRequest)`, `findRecordedResult(request: SaleRequest)` |
| `Clock` | `now()` |
| `ReservationService` | `recordReservation(itemCode, customerRef, conditions, userId)`, `evaluateExpiry(asOf)` |
| `ReservationPolicy` | `calculateExpiry(currentDateTime)` |
| `ReservationRepository` | `findActiveByItemCode(itemCode)`, `findAllActive()`, `save(reservation)`, `update(reservation)` |
| `OfflineReconciliationService` | `enterOfflineTransaction(submissionId, offlineRef, saleDate, recordedBy, lines)`, `reconcile(entryId)`, `resolve(entryId, decision, note)` |
| `OfflineTransactionRepository` | `findByEntryId(entryId)`, `findBySubmissionId(submissionId)`, `existsOtherWithRef(offlineRef, entryId)`, `save(transaction)`, `countByStatus(status)` |
| `ConflictChecker` | `check(transaction)` |
| `SaleService` | `recordSale(request: SaleRequest)`, `findRecordedResult(request: SaleRequest)` |
| `ProductCatalogue` | `findItem(itemCode)` |
| `SaleRepository` | `findByIdempotencyKey(key)`, `persist(sale, record)` |

## Operation / sequence correspondence

The following table defines the mapping from use-case interactions to operations in the integrated class model. The shared contracts provide the canonical names at integration boundaries.

| Slice | Sequence message(s) | Receiving class / interface |
|---|---|---|
| 1 — Reserve | `recordReservation`, `validateRequest` | `ReservationService` |
| 1 — Reserve | `getStatus`, `reserveIfAvailable` | `StockAvailabilityPort` |
| 1 — Reserve | `findActiveByItemCode`, `save` | `ReservationRepository` |
| 1 — Reserve | `now`, `calculateExpiry`, `create` | `Clock`, `ReservationPolicy`, `Reservation`, respectively |
| 1 — Expiry | `evaluateExpiry`, `keepActive` | `ReservationService` |
| 1 — Expiry | `findAllActive`, `update` | `ReservationRepository` |
| 1 — Expiry | `getAgreedExpiry`, `expire` | `Reservation` |
| 1 — Expiry | `getStatus`, `releaseIfReserved` | `StockAvailabilityPort` |
| 3 — Enter / reconcile / resolve | `enterOfflineTransaction`, `reconcile`, `resolve`, `requireCoordinatorRole`, `requireManagerRole` | `OfflineReconciliationService` |
| 3 — Enter / reconcile / resolve | `findBySubmissionId`, `findByEntryId`, `existsOtherWithRef`, `save`, `countByStatus` | `OfflineTransactionRepository` |
| 3 — Reconcile | `check`, `getStatus`, `findRecordedResult`, `recordSale` | `ConflictChecker`, `StockAvailabilityPort`, `SaleRecordingPort`, respectively |
| 3 — Entry and state changes | `create`, `markReconciled`, `refer`, `resolve` | `OfflineTransaction` |
| 3 — Entry / resolution timestamps | `now` | `Clock` |
| 4 — Sale | `recordSale`, `findRecordedResult` | `SaleRecordingPort`, implemented by `SaleService` |
| 4 — Sale | `validateRequestAndIdempotency` | `SaleService` |
| 4 — Sale | `findByIdempotencyKey`, `persist` | `SaleRepository` |
| 4 — Sale | `findItem`, `getStatus`, `sellAllIfAvailable`, `now` | `ProductCatalogue`, `StockAvailabilityPort` (both stock operations), `Clock` |
| 4 — Sale | `create`, `addLine` | `Sale` (`create` and `addLine`), `SaleLine` (`create`) |

The `create` messages for `Reservation`, `OfflineTransaction`, `Sale` and `SaleLine` represent creation operations on the corresponding entity classes. `Sale.addLine(line)` adds the created line to its sale aggregate.

### Shared naming conventions

- Reservation stock transitions use `reserveIfAvailable` and `releaseIfReserved`, rather than the older `markReserved` and `release` message names.
- `Clock` supplies time through `now()` only; working-day calculations belong to `ReservationPolicy`.
- Offline reconciliation and resolution select records by `entryId`, not by the potentially repeated `offlineRef`. Repository lookup uses `findByEntryId`.
- Stock availability queries use `getStatus(itemCode)`.
- Offline sale recording uses `recordSale(request: SaleRequest)` and the returned `saleRef`.
- Batch stock updates use `sellAllIfAvailable(stockLines, idempotencyKey)`, where each `StockLine` contains `itemCode` and `quantity`.

## Design boundaries and consistency rules

- Slice 3 depends on `SaleRecordingPort`, not directly on `SaleService`, `SaleRepository`, `Sale` or `SaleLine`.
- Slices 1, 3 and 4 share `StockAvailabilityPort`; all four use `Clock`. Only the stock provider performs stock state transitions; Slice 3 is a read-only consumer of stock.
- The stock status vocabulary is `Available`, `Reserved`, `Sold` and `Unknown`. Reserved and Sold items are not eligible for sale within this design scope. Unknown identifies an unrecognised item code.
- A `SaleRequest` contains `idempotencyKey`, `processedBy`, `channel`, optional `customerRef`, conditional `saleDate`, optional `sourceRef` and one or more `SaleRequestLine` objects. Each line contains `itemCode`, `quantity`, `soldPrice` and optional `discountAmount`.
- `Recorded(saleRef)` and `Rejected(reason)` are the expected business outcomes of `SaleRecordingPort`. Technical failures are reported separately and must not be interpreted as confirmation of a sale.
- Repeating the same sale request with the same idempotency key and payload returns the original recorded result. Reusing the key with a different payload is rejected with `IdempotencyKeyConflict`. Offline reconciliation retries retain the original `entryId` as their sale idempotency key.
- The offline transaction lifecycle is `AwaitingReconciliation`, `Reconciled`, `ReferredToManager` and `Resolved`. Only a confirmed sale permits reconciliation; Manager resolution does not create a sale.
- Sale recording requires all-or-nothing consistency across sale persistence, the idempotency result and stock changes. Reservation creation and expiry likewise require consistent reservation and stock changes. The class diagram specifies these guarantees at design level; the underlying transaction or compensation mechanism is outside its modelling scope.
- `ReservationPolicy` owns expiry and working-day calculations. No universal reservation duration is hard-coded into the application service or the `Clock` interface.
- Stock quantity and pricing validation follow the shared sale and stock contracts. The class diagram retains `itemCode` and `quantity` without defining a new inventory storage model or additional pricing policy.


### Slice 2 operation mapping

`OrderFulfilmentService`: `viewOrder`, `markReady`, `recordCollection`, `recordCustomerDecision`; `CustomerOrderRepository`: `findById`, `save`; `CustomerOrder`: `getStatus`, `getLineDetails`, `findLine`, `markLineReady`, `markLineCollected`, `recordLineDecision`, `recalculateStatus`; `OrderLine`: `getLineId`, `getStatus`, `markReady`, `markCollected`, `applyDecision`, `isClosed`; `CurrentUser.getUserId` (proposed) and `Clock.now`. The detailed per-operation sequence files are the reference for UC-04.
