# Slice 1 — Reserve an Item (UC-02)

**Working owner:** Marian Andrei.

**Links:** US-01, FR-04, FR-05, SC-01, SC-02, SC-03, A-01, A-02, Q-01.

**Controller / Provider:** `ReservationService`

**Shared interface used:** `StockAvailabilityPort`

## 1. Purpose

This slice is responsible for managing customer reservations for the Local Craft Marketplace.

It allows a Shop Volunteer to reserve an available item for a customer while maintaining accurate reservation records, stock availability and agreed reservation expiry dates.

The slice coordinates the reservation process and ensures that an item cannot have multiple active reservations. It also evaluates reservation expiry and releases items when their reservation period ends, provided no other commitment applies.

The slice does not own product catalogue management, customer sales, customer orders or offline transaction reconciliation.

## 2. Scope

### In scope

- Accept a customer reservation request.
- Validate the customer reference and reservation conditions.
- Check whether the requested item exists.
- Check stock availability.
- Check for conflicting active reservations.
- Calculate the agreed expiry date using `ReservationPolicy`.
- Coordinate the creation and storage of Reservation records.
- Request stock status updates through `StockAvailabilityPort`.
- Evaluate active reservations against their agreed expiry dates.
- Expire reservations whose expiry dates have been reached.
- Release expired reservations where no other commitment applies.
- Return explicit success or rejection results.

### Out of scope

- Creating and maintaining product records.
- Processing customer sales.
- Managing customer orders and partial fulfilment.
- Managing maker commissions.
- Reconciling offline market transactions.

These responsibilities belong to other project areas or require separate agreement.

## 3. Main Responsibilities

`ReservationService` coordinates the customer reservation workflow.

Its responsibilities include:

1. Receiving requests through `recordReservation()`.
2. Validating customer references and reservation conditions.
3. Checking whether the requested item exists and is available.
4. Checking for conflicting active reservations.
5. Obtaining the agreed expiry date through `ReservationPolicy`.
6. Coordinating reservation creation and storage.
7. Requesting stock status changes from Available to Reserved.
8. Evaluating active reservations through `evaluateExpiry()`.
9. Expiring reservations that have reached their agreed expiry dates.
10. Requesting the release of expired items where no other commitment applies.
11. Returning the appropriate operation result.

Detailed class responsibilities are documented separately in the CRC Cards.

## 4. Provides and Requires

### Provides

| Component | Purpose |
|---|---|
| `ReservationService` | Coordinates customer reservation and expiry operations. |

### Requires

| Component | Purpose |
|---|---|
| `ReservationRepository` | Stores and retrieves reservation records. |
| `StockAvailabilityPort` | Checks and updates stock availability. |
| `ReservationPolicy` | Calculates agreed reservation expiry dates. |
| `Clock` | Provides current date and working-day calculations. |

The exact method signatures and result types are maintained in the shared interface and operation contract documents.

## 5. Integration Boundaries

### Interaction with other slices

- **Customer Sale Slice:** Provides shared stock availability information. A reserved item must not become available for another customer's sale without the appropriate reservation-holder rule being agreed.
- **Customer Order Slice:** Must use agreed shared contracts if an order-related workflow needs to interact with reserved stock.
- **Offline Transactions Slice:** Must account for reserved items when checking stock availability during offline transaction reconciliation.
- **Other Stock-Dependent Slices:** Must use the agreed `StockAvailabilityPort` contract when checking or changing item availability.

### Shared contract requirements

- Item identification must be consistent across all slices.
- Stock availability operations must use the agreed shared interface.
- Reservation status and expiry conventions must be compatible with the shared design.
- Changes to shared interfaces must be reviewed by affected slice owners before integration.
- Each slice must provide its own in-memory fake implementations and run the shared contract tests.

## 6. Consistency and Failure Handling

The reservation operation must maintain consistency between reservation records and stock availability.

If a reservation request is invalid, conflicting or unavailable, the entire operation must be rejected.

A failed reservation must not create a Reservation record or change the item's stock status.

During expiry evaluation, only active reservations whose agreed expiry dates have been reached or passed should be expired.

Expired items must only be released when no other commitment applies.

Repeated expiry evaluation must not result in duplicate expiry changes or repeated stock releases.

The technical transaction and rollback mechanism for reservation creation and stock updating must be agreed and documented separately in the technical design notes.

## 7. Related Artefacts

The following documents contain the detailed design information for this slice:

| Artefact | Purpose |
|---|---|
| `design/operation-contract.md` | Operation signatures, preconditions, postconditions and failure guarantees. |
| `design/crc-cards.md` | Class responsibilities and collaborators. |
| `design/operation-error-catalogue.md` | Error definitions and expected handling. |
| `design/shared-interface.md` | Shared interface definitions and method signatures. |
| `design/design-notes.md` | Technical decisions, expiry policy and consistency considerations. |
| `design/` Slice 1 Gherkin feature file | Behavioural scenarios and acceptance evidence. |
| `design/design-class-diagram.md` | Structural relationships and class design, once agreed. |
| `design/` Slice 1 sequence diagrams | Object interactions for reservation creation and expiry evaluation. |
