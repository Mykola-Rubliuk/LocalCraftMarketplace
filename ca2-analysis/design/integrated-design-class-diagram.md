# Integrated Design Class Diagram

**Scope:** Slice 1 — Manage Reservation (UC-02), Slice 3 — Reconcile Offline Transactions (proposed UC-10), and Slice 4 — Process a Customer Sale (UC-01).

**Diagram source:** [`integrated-design-class-diagram.puml`](integrated-design-class-diagram.puml)

The diagram presents one integrated design. It groups each slice's controller, domain objects and repositories while showing the shared contracts that connect the slices. Slice 2 is intentionally excluded because its design is not ready for integration.

## Integration structure

| Shared abstraction | Provider / implementation | Consumers | Responsibility |
|---|---|---|---|
| `StockAvailabilityPort` | Shared stock capability; concrete provider is not assigned in the current documents | Slice 1, Slice 3 and Slice 4 | One stock-status vocabulary and controlled stock transitions |
| `SaleRecordingPort` | `SaleService` in Slice 4 | Slice 3, and other approved sale-recording callers | One entry point for validating and recording a sale |
| `Clock` | Shared time abstraction; concrete provider is not assigned in the current documents | Slice 1, Slice 3 and Slice 4 | Current date/time via `now()` |

## How the three slices collaborate

1. **Slice 1 — Reservation:** `ReservationService` checks stock through `StockAvailabilityPort`, checks existing reservations through `ReservationRepository`, obtains the current time from `Clock`, and asks `ReservationPolicy` to calculate the agreed expiry. It then reserves stock through `reserveIfAvailable`. Expiry processing uses `releaseIfReserved` only when the reservation is eligible and no other commitment applies.
2. **Slice 3 — Offline reconciliation:** `OfflineReconciliationService` persists and retrieves offline entries, and delegates duplicate/stock checks to `ConflictChecker`. The checker uses `StockAvailabilityPort.getStatus` only. If all lines are clear, the service submits one complete `SaleRequest` to `SaleRecordingPort`; it does not create `Sale`/`SaleLine` records or mutate stock itself.
3. **Slice 4 — Customer sale:** `SaleService` implements `SaleRecordingPort`. It validates the request and idempotency key, resolves item and maker details through `ProductCatalogue`, reads stock status, creates the sale and its lines, and asks `StockAvailabilityPort.sellAllIfAvailable` to perform the all-or-nothing stock transition. `SaleRepository` stores the sale and idempotency result.

## Operation alignment

The operations shown on the classes retain the names used in the current object-interaction diagrams and operation contracts, including:

- `getStatus`, `reserveIfAvailable`, `releaseIfReserved`, `sellAllIfAvailable`;
- `recordSale(request: SaleRequest)`;
- `recordReservation`, `evaluateExpiry`, `calculateExpiry`, `findActiveByItemCode`, `findAllActive`;
- `enterOfflineTransaction`, `reconcile`, `resolve`, `check`, `existsOtherWithRef`;
- `findItem`, `findResultByIdempotencyKey`, `persist`, `now`.

## Operation / sequence correspondence

The public and collaborator operations in the integrated diagram cover the messages used by the current object-interaction sequences:

| Slice | Sequence message(s) | Receiving class / interface |
|---|---|---|
| 1 — Reserve | `recordReservation`, `validateRequest`, `getStatus`, `findActiveByItemCode`, `now`, `calculateExpiry`, `create`, `reserveIfAvailable`, `save` | `ReservationService`, `StockAvailabilityPort`, `ReservationRepository`, `Clock`, `ReservationPolicy`, `Reservation` |
| 1 — Expiry | `evaluateExpiry`, `findAllActive`, `getAgreedExpiry`, `getStatus`, `releaseIfReserved`, `expire`, `update`, `keepActive` | `ReservationService`, `ReservationRepository`, `Reservation`, `StockAvailabilityPort` |
| 3 — Reconcile | `reconcile`, `requireCoordinatorRole`, `findByEntryId`, `check`, `existsOtherWithRef`, `getStatus`, `recordSale`, `markReconciled`, `refer`, `save` | `OfflineReconciliationService`, `OfflineTransactionRepository`, `ConflictChecker`, `StockAvailabilityPort`, `SaleRecordingPort`, `OfflineTransaction` |
| 3 — Enter / resolve | `enterOfflineTransaction`, `findBySubmissionId`, `resolve`, `requireManagerRole`, `now` | `OfflineReconciliationService`, `OfflineTransactionRepository`, `OfflineTransaction`, `Clock` |
| 4 — Sale | `recordSale`, `validateRequestAndIdempotency`, `findResultByIdempotencyKey`, `findItem`, `getStatus`, `now`, `create`, `addLine`, `sellAllIfAvailable`, `persist` | `SaleRecordingPort`, `SaleService`, `SaleRepository`, `ProductCatalogue`, `StockAvailabilityPort`, `Clock`, `Sale`, `SaleLine` |

The `create` messages for `Reservation`, `Sale`, and `SaleLine` are modelled as creation operations on the corresponding entity classes. The result types in the diagram make the contract's documented business outcomes and technical outcomes visible without changing their established names.

## Design boundaries and unresolved points

- Slice 3 depends on `SaleRecordingPort`, not on `SaleService`, `SaleRepository`, `Sale`, or `SaleLine` directly.
- All three slices depend on the same `StockAvailabilityPort` and `Clock` abstractions. The concrete stock and clock providers are not named in the current source documents, so the diagram does not invent provider classes.
- Slice 3 is a read-only consumer of stock. Only the sale-recording flow in Slice 4 performs the stock transition to `Sold`.
- The sale request contains the shared fields `idempotencyKey`, `processedBy`, `channel`, optional `customerRef`, conditional `saleDate`, optional `sourceRef`, and one or more lines.
- `Recorded(saleRef)` and `Rejected(reason)` are the business outcomes of `SaleRecordingPort`. Technical failures remain distinct from business refusals.
- All-or-nothing stock updates are required, but the mechanism that makes `SaleRepository` persistence and stock persistence atomic (or safely compensatable) is still unresolved. The diagram does not imply that this has already been implemented.
- The exact `itemCode` / `quantity` semantics, reservation expiry policy/calendar, and reservation-holder sale policy remain open in the existing decision log / open questions.
- UC-10 / Slice 3 remains a proposed design pending PB-01 / Q-SH-08 confirmation.

## UML modelling note

`StockOperationResult`, `StockUpdated`, `StockRejected`, `ReservationResult`, `ValidationResult`, `CatalogueItemDetails`, and `PersistenceResult` are explicit design-level UML types used to make the documented operations and outcomes readable. Their final implementation names and shapes require group agreement. They do not change the outcome names already defined in `design/shared-interface-catalogue.md` and `design/operation-error-catalogue.md`.
