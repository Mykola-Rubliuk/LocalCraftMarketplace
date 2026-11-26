# Integrated Design Class Diagram

**Scope:** Slice 1 — Manage Reservation (UC-02), Slice 3 — Reconcile Offline Transactions (UC-10), and Slice 4 — Process a Customer Sale (UC-01).

**Diagram source:** [`integrated-design-class-diagram.puml`](integrated-design-class-diagram.puml)

The diagram presents the integrated object-oriented design of these three behavioural slices. It groups their application service controllers, domain objects and repositories, and identifies the shared contracts that connect them. Slice 2 — Fulfil Order Lines (UC-04) is documented separately and is outside the scope of this diagram version.

## Integration structure

| Shared abstraction | Provider / implementation | Consumers | Responsibility |
|---|---|---|---|
| `StockAvailabilityPort` | Shared stock capability | Slice 1, Slice 3 and Slice 4 | Provide a common stock-status vocabulary and controlled stock transitions. |
| `SaleRecordingPort` | `SaleService` in Slice 4 | Slice 3 and in-store sale callers | Provide a single entry point for validating and recording sales. |
| `Clock` | Shared time abstraction | Slice 1, Slice 3 and Slice 4 | Supply the current date and time through `now()`. |

Concrete stock and clock implementations are outside the abstraction level of this design diagram.

## How the three slices collaborate

1. **Slice 1 — Manage Reservation:** `ReservationService` validates reservation details, reads stock availability through `StockAvailabilityPort`, and checks existing reservations through `ReservationRepository`. It obtains the current time from `Clock` and delegates expiry calculation to `ReservationPolicy`. It creates an Active `Reservation` and requests `reserveIfAvailable`. Reservation persistence and stock changes must be consistent. During expiry evaluation, eligible reservations become Expired and `releaseIfReserved` releases the associated stock only when no other commitment applies.
2. **Slice 3 — Reconcile Offline Transactions:** `OfflineReconciliationService` records offline entries through `OfflineTransactionRepository`. Each entry has a unique internal `entryId`; `offlineRef` is retained for duplicate-reference checks and `submissionId` supports safe resubmission. `ConflictChecker` checks duplicate references and reads stock through `StockAvailabilityPort.getStatus`. Duplicate or conflicting transactions are referred to the Manager without recording a new sale. A clean transaction is submitted as one complete `SaleRequest` to `SaleRecordingPort`, using `entryId` as its idempotency key. A confirmed `Recorded(saleRef)` result permits the transaction to become Reconciled. Manager resolution records the decision and note without creating a sale.
3. **Slice 4 — Process a Customer Sale:** `SaleService` implements `SaleRecordingPort`. It validates the request and idempotency key, obtains product and maker details from `ProductCatalogue`, and checks availability through `StockAvailabilityPort`. It creates `Sale` and `SaleLine` data, retaining product and maker attribution, quantity, selling price and any applicable discount. `sellAllIfAvailable` performs the all-or-nothing stock transition, and `SaleRepository` persists the sale and its idempotency result. `Recorded(saleRef)` is returned only after the sale and stock changes have been committed consistently.

## Operation alignment

The integrated model uses the operation names and signatures defined by the shared contracts and represented in the class diagram:

| Class / interface | Operations |
|---|---|
| `StockAvailabilityPort` | `getStatus(itemCode)`, `reserveIfAvailable(itemCode)`, `releaseIfReserved(itemCode)`, `sellAllIfAvailable(stockLines, idempotencyKey)` |
| `SaleRecordingPort` | `recordSale(request: SaleRequest)` |
| `Clock` | `now()` |
| `ReservationService` | `recordReservation(itemCode, customerRef, conditions)`, `evaluateExpiry(asOf)` |
| `ReservationPolicy` | `calculateExpiry(currentDateTime)` |
| `ReservationRepository` | `findActiveByItemCode(itemCode)`, `findAllActive()`, `save(reservation)`, `update(reservation)` |
| `OfflineReconciliationService` | `enterOfflineTransaction(submissionId, offlineRef, saleDate, processedBy, lines)`, `reconcile(entryId)`, `resolve(entryId, decision, note)` |
| `OfflineTransactionRepository` | `findByEntryId(entryId)`, `findBySubmissionId(submissionId)`, `existsOtherWithRef(offlineRef, entryId)`, `save(transaction)`, `countByStatus(status)` |
| `ConflictChecker` | `check(transaction)` |
| `SaleService` | `recordSale(request: SaleRequest)` |
| `ProductCatalogue` | `findItem(itemCode)` |
| `SaleRepository` | `findResultByIdempotencyKey(key)`, `persist(sale, idempotencyKey)` |

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
| 3 — Reconcile | `check`, `getStatus`, `recordSale` | `ConflictChecker`, `StockAvailabilityPort`, `SaleRecordingPort`, respectively |
| 3 — Entry and state changes | `create`, `markReconciled`, `refer`, `resolve` | `OfflineTransaction` |
| 3 — Entry / resolution timestamps | `now` | `Clock` |
| 4 — Sale | `recordSale` | `SaleRecordingPort`, implemented by `SaleService` |
| 4 — Sale | `validateRequestAndIdempotency` | `SaleService` |
| 4 — Sale | `findResultByIdempotencyKey`, `persist` | `SaleRepository` |
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
- The three slices share `StockAvailabilityPort` and `Clock`. Only the stock provider performs stock state transitions; Slice 3 is a read-only consumer of stock.
- The stock status vocabulary is `Available`, `Reserved`, `Sold` and `Unknown`. Reserved and Sold items are not eligible for sale within this design scope. Unknown identifies an unrecognised item code.
- A `SaleRequest` contains `idempotencyKey`, `processedBy`, `channel`, optional `customerRef`, conditional `saleDate`, optional `sourceRef` and one or more `SaleRequestLine` objects. Each line contains `itemCode`, `quantity`, `soldPrice` and optional `discountAmount`.
- `Recorded(saleRef)` and `Rejected(reason)` are the expected business outcomes of `SaleRecordingPort`. Technical failures are reported separately and must not be interpreted as confirmation of a sale.
- Repeating the same sale request with the same idempotency key and payload returns the original recorded result. Reusing the key with a different payload is rejected with `IdempotencyKeyConflict`. Offline reconciliation retries retain the original `entryId` as their sale idempotency key.
- The offline transaction lifecycle is `AwaitingReconciliation`, `Reconciled`, `ReferredToManager` and `Resolved`. Only a confirmed sale permits reconciliation; Manager resolution does not create a sale.
- Sale recording requires all-or-nothing consistency across sale persistence, the idempotency result and stock changes. Reservation creation and expiry likewise require consistent reservation and stock changes. The class diagram specifies these guarantees at design level; the underlying transaction or compensation mechanism is outside its modelling scope.
- `ReservationPolicy` owns expiry and working-day calculations. No universal reservation duration is hard-coded into the application service or the `Clock` interface.
- Stock quantity and pricing validation follow the shared sale and stock contracts. The class diagram retains `itemCode` and `quantity` without defining a new inventory storage model or additional pricing policy.