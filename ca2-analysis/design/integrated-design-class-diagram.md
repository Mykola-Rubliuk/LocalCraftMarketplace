# Integrated Design Class Diagram

**Scope:** Slice 1 — Manage Reservation (UC-02), Slice 2 — Fulfil Order Lines (UC-04), Slice 3 — Reconcile Offline Transactions (UC-10), and Slice 4 — Process a Customer Sale (UC-01).

**Diagram source:** [`integrated-design-class-diagram.puml`](integrated-design-class-diagram.puml)

The diagram presents the integrated object-oriented design of these four behavioural slices. It groups their application service controllers, domain objects and repositories, and identifies the shared contracts that connect them.

## Integration structure

| Shared abstraction | Provider / implementation | Consumers | Responsibility |
|---|---|---|---|
| `StockAvailabilityPort` | Shared stock capability | Slice 1, Slice 3 and Slice 4 | Provide a common stock-status vocabulary and controlled stock transitions. |
| `SaleRecordingPort` | `SaleService` in Slice 4 | Slice 3 and in-store sale callers | Provide a single entry point for validating and recording sales. |
| `Clock` | Shared time abstraction | Slice 1, Slice 2, Slice 3 and Slice 4 | Supply the current date and time through `now()`. |
| `CurrentUser` | Shared identity abstraction | Slice 1, Slice 2, Slice 3 and Slice 4 | Supply the signed-in user's ID through `getUserId()`; it does not decide authorisation (D-CA2-20). |

Concrete stock, clock and identity implementations are outside the abstraction level of this design diagram.

## How the four slices collaborate

1. **Slice 1 — Manage Reservation:** `ReservationService` validates reservation details, reads stock availability through `StockAvailabilityPort`, and checks existing reservations through `ReservationRepository`. It obtains the current time from `Clock` and delegates expiry calculation to `ReservationPolicy`. It creates an Active `Reservation`, recording the signed-in user's ID from `CurrentUser` as `createdByUserId`, and requests `reserveIfAvailable`. Reservation persistence and stock changes must be consistent. During expiry evaluation, eligible reservations become Expired and `releaseIfReserved` releases the associated stock only when no other commitment applies.
2. **Slice 2 — Fulfil Order Lines:** `OrderFulfilmentService` retrieves a `CustomerOrder` and its lines through `CustomerOrderRepository`. `viewOrder` returns the order status and each line's ID and status, or refuses with `OrderNotFound`. For a line change, the service obtains the user's identity from `CurrentUser` and the time from `Clock`, then asks the `CustomerOrder` to apply the change. `OrderLine` enforces its own transition rules and records who made the last change and when, plus the `decisionReason` for a customer decision. After an accepted change, `CustomerOrder` recalculates its status and the service saves the order. `Recorded(lineStatus, orderStatus)` is returned only after the commit. This slice uses neither `StockAvailabilityPort` nor `SaleRecordingPort`.
3. **Slice 3 — Reconcile Offline Transactions:** `OfflineReconciliationService` records offline entries through `OfflineTransactionRepository`. Each entry has a unique internal `entryId`; `offlineRef` is retained for duplicate-reference checks and `submissionId` supports safe resubmission. `ConflictChecker` checks duplicate references and reads stock through `StockAvailabilityPort.getStatus`. Duplicate or conflicting transactions are referred to the Manager without recording a new sale. A clean transaction is submitted as one complete `SaleRequest` to `SaleRecordingPort`, using `entryId` as its idempotency key. A confirmed `Recorded(saleRef)` result permits the transaction to become Reconciled. Manager resolution records the decision and note without creating a sale. The service takes `recordedBy`, `resolvedBy` and the `processedBy` of a new `SaleRequest` from `CurrentUser`; a retry keeps the stored `processedBy`.
4. **Slice 4 — Process a Customer Sale:** `SaleService` implements `SaleRecordingPort`. It validates the request and idempotency key, obtains product and maker details from `ProductCatalogue`, and checks availability through `StockAvailabilityPort`. It creates `Sale` and `SaleLine` data, retaining product and maker attribution, quantity, selling price and any applicable discount. `sellAllIfAvailable` performs the all-or-nothing stock transition, and `SaleRepository` persists the sale and its idempotency result. `Recorded(saleRef)` is returned only after the sale and stock changes have been committed consistently. For a new `InStore` sale, `SaleService` also checks that `processedBy` matches the signed-in user's ID from `CurrentUser`.

## Operation alignment

The integrated model uses the operation names and signatures defined by the shared contracts and represented in the class diagram:

| Class / interface | Operations |
|---|---|
| `StockAvailabilityPort` | `getStatus(itemCode)`, `reserveIfAvailable(itemCode)`, `releaseIfReserved(itemCode)`, `sellAllIfAvailable(stockLines, idempotencyKey)` |
| `SaleRecordingPort` | `recordSale(request: SaleRequest)` |
| `Clock` | `now()` |
| `CurrentUser` | `getUserId()` |
| `ReservationService` | `recordReservation(itemCode, customerRef, conditions)`, `evaluateExpiry(asOf)` |
| `ReservationPolicy` | `calculateExpiry(currentDateTime)` |
| `ReservationRepository` | `findActiveByItemCode(itemCode)`, `findAllActive()`, `save(reservation)`, `update(reservation)` |
| `OrderFulfilmentService` | `viewOrder(orderId)`, `markReady(orderId, lineId)`, `recordCollection(orderId, lineId)`, `recordCustomerDecision(orderId, lineId, decision, decisionReason)` |
| `CustomerOrderRepository` | `findById(orderId)`, `save(order)` |
| `CustomerOrder` | `getStatus()`, `getLineDetails()`, `markLineReady(lineId, changedBy, changedAt)`, `markLineCollected(lineId, changedBy, changedAt)`, `recordLineDecision(lineId, decision, decisionReason, changedBy, changedAt)`, `findLine(lineId)`, `recalculateStatus()` |
| `OrderLine` | `getLineId()`, `getStatus()`, `markReady(changedBy, changedAt)`, `markCollected(changedBy, changedAt)`, `applyDecision(decision, decisionReason, changedBy, changedAt)`, `isClosed()` |
| `OfflineReconciliationService` | `enterOfflineTransaction(submissionId, offlineRef, saleDate, lines)`, `reconcile(entryId)`, `resolve(entryId, decision, note)` |
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
| 1 — Reserve | `getUserId` | `CurrentUser` |
| 1 — Expiry | `evaluateExpiry`, `keepActive` | `ReservationService` |
| 1 — Expiry | `findAllActive`, `update` | `ReservationRepository` |
| 1 — Expiry | `getAgreedExpiry`, `expire` | `Reservation` |
| 1 — Expiry | `getStatus`, `releaseIfReserved` | `StockAvailabilityPort` |
| 2 — View order | `viewOrder` | `OrderFulfilmentService` |
| 2 — View order / line changes | `findById` | `CustomerOrderRepository` |
| 2 — View order | `getStatus`, `getLineDetails` | `CustomerOrder` |
| 2 — View order | `getLineId`, `getStatus` | `OrderLine` |
| 2 — Line changes | `markReady`, `recordCollection`, `recordCustomerDecision` | `OrderFulfilmentService` |
| 2 — Line changes | `getUserId`, `now` | `CurrentUser`, `Clock`, respectively |
| 2 — Line changes | `markLineReady`, `markLineCollected`, `recordLineDecision`, `findLine`, `recalculateStatus` | `CustomerOrder` |
| 2 — Line changes | `markReady`, `markCollected`, `applyDecision`, `isClosed` | `OrderLine` |
| 2 — Line changes | `save` | `CustomerOrderRepository` |
| 3 — Enter / reconcile / resolve | `enterOfflineTransaction`, `reconcile`, `resolve`, `requireCoordinatorRole`, `requireManagerRole` | `OfflineReconciliationService` |
| 3 — Enter / reconcile / resolve | `findBySubmissionId`, `findByEntryId`, `existsOtherWithRef`, `save`, `countByStatus` | `OfflineTransactionRepository` |
| 3 — Reconcile | `check`, `getStatus`, `recordSale` | `ConflictChecker`, `StockAvailabilityPort`, `SaleRecordingPort`, respectively |
| 3 — Entry and state changes | `create`, `markReconciled`, `refer`, `resolve` | `OfflineTransaction` |
| 3 — Entry / resolution timestamps | `now` | `Clock` |
| 3 — Reconcile | `getUserId` | `CurrentUser` |
| 4 — Sale | `recordSale` | `SaleRecordingPort`, implemented by `SaleService` |
| 4 — Sale | `validateRequestAndIdempotency` | `SaleService` |
| 4 — Sale | `findResultByIdempotencyKey`, `persist` | `SaleRepository` |
| 4 — Sale | `findItem`, `getStatus`, `sellAllIfAvailable`, `now` | `ProductCatalogue`, `StockAvailabilityPort` (both stock operations), `Clock` |
| 4 — Sale | `getUserId` | `CurrentUser` |
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
- Slices 1, 3 and 4 share `StockAvailabilityPort`, and all four slices share `Clock`. Only the stock provider performs stock state transitions; Slice 3 is a read-only consumer of stock.
- Order line statuses are `BeingMade`, `Ready`, `Collected`, `Cancelled` and `Substituted`. The allowed transitions are `BeingMade` to `Ready`, `Ready` to `Collected`, and `BeingMade` or `Ready` to `Cancelled` or `Substituted`.
- An order is `Completed` when all its lines are `Collected`, `Cancelled` or `Substituted`, and `Open` otherwise. `Completed` does not mean that any line was collected.
- A customer decision requires a `decisionReason` from one predefined list. The list includes `NotGiven`; its other values are not yet agreed. The line status is checked before the reason, so a closed line is refused with `InvalidStatusChange`. The customer's approval is not verified by the system (D-CA2-14).
- The expected refusals in Slice 2 are `OrderNotFound`, `InvalidStatusChange` and `ReasonNotSupplied`. A refusal changes nothing. A technical failure leaves no partial change to the line or order.
- The Slice 2 contracts name their results `Recorded(lineStatus, orderStatus)` and `Rejected(reason)`. The diagram models them as `LineChangeRecorded`, `LineChangeRejected` and `OrderViewRejected` to keep them distinct from the `SaleRecordingResult` classes. A successful `viewOrder` is modelled as `OrderViewed`.
- `OrderLine` receives the change time as a value and does not depend on `Clock` or `CurrentUser`. `LineTransitionResult` models whether the line accepted a change or why it refused it.
- Recording a new customer order is outside this model (Q-SH-11).
- All four slices obtain the signed-in user's ID from `CurrentUser` (D-CA2-20). It is not a separate operation input, and `CurrentUser` does not decide authorisation. Entities receive the ID as a value.
- A new `InStore` sale is refused with `UnauthorisedProcessor` if `processedBy` does not match the signed-in user. This is a Slice 4 rule; D-CA2-20 does not decide it. `OfflineMarket` requests are not compared. How an offline request's origin and retry permission are checked remains open (Q-SH-12, Q-SH-13).
- The stock status vocabulary is `Available`, `Reserved`, `Sold` and `Unknown`. Reserved and Sold items are not eligible for sale within this design scope. Unknown identifies an unrecognised item code.
- A `SaleRequest` contains `idempotencyKey`, `processedBy`, `channel`, optional `customerRef`, conditional `saleDate`, optional `sourceRef` and one or more `SaleRequestLine` objects. Each line contains `itemCode`, `quantity`, `soldPrice` and optional `discountAmount`.
- `Recorded(saleRef)` and `Rejected(reason)` are the expected business outcomes of `SaleRecordingPort`. Technical failures are reported separately and must not be interpreted as confirmation of a sale.
- Repeating the same sale request with the same idempotency key and payload returns the original recorded result. Reusing the key with a different payload is rejected with `IdempotencyKeyConflict`. Offline reconciliation retries retain the original `entryId` as their sale idempotency key.
- The offline transaction lifecycle is `AwaitingReconciliation`, `Reconciled`, `ReferredToManager` and `Resolved`. Only a confirmed sale permits reconciliation; Manager resolution does not create a sale.
- Sale recording requires all-or-nothing consistency across sale persistence, the idempotency result and stock changes. Reservation creation and expiry likewise require consistent reservation and stock changes. The class diagram specifies these guarantees at design level; the underlying transaction or compensation mechanism is outside its modelling scope.
- `ReservationPolicy` owns expiry and working-day calculations. No universal reservation duration is hard-coded into the application service or the `Clock` interface.
- Stock quantity and pricing validation follow the shared sale and stock contracts. The class diagram retains `itemCode` and `quantity` without defining a new inventory storage model or additional pricing policy.