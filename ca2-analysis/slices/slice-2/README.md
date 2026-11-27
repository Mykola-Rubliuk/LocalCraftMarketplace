# Slice 2 — Fulfil Order Lines (UC-04)

**Working owner:** Maryna Tarasova.

**Links:** US-02, FR-06, FR-07, BR-02, BR-03, A-04, Q-03, SC-04, D-CA2-06, D-CA2-14, D-CA2-15, D-CA2-20.

**Controller:** `OrderFulfilmentService`

**Shared interfaces consumed:** `Clock`, `CurrentUser`

## 1. Purpose

This slice is responsible for fulfilling the lines of existing customer orders for the Local Craft Marketplace.

It allows an authorised Shop Volunteer to view an order, mark a line ready or collected, and record a customer's decision to substitute or cancel a line. Each line keeps its own status, so the progress of each part of an order remains distinguishable.

The slice coordinates order-line fulfilment but does not own order recording, sale processing, reservations, stock availability or offline transaction reconciliation.

## 2. Scope

### In scope

- View an order with its order status and the status of each line.
- Mark an order line `Ready`.
- Record the collection of a `Ready` line.
- Record a customer decision (`Substituted` or `Cancelled`) with its reason.
- Enforce the allowed line status transitions.
- Record who made the last change to a line and when.
- Recalculate the order status after an accepted line change.
- Return the order details, or a result for a recorded or refused change.

### Out of scope

- Recording new customer orders. No use case covers this yet (Q-SH-11).
- Verifying the customer's approval of a substitution or cancellation. The customer approves offstage (D-CA2-14).
- Reverting a line to its previous status. This is a future extension (D-CA2-16).
- Managing the list of decision reasons. This is a future extension (D-CA2-17).
- Reading order status through `UC-07`.
- Processing sales, managing reservations or reconciling offline transactions.

## 3. Main Responsibilities

`OrderFulfilmentService` coordinates the order-line fulfilment workflow.

It provides four operations:

| Operation | Purpose |
|---|---|
| `viewOrder(orderId)` | Show the order status and each line's ID and status. |
| `markReady(orderId, lineId)` | Change a `BeingMade` line to `Ready`. |
| `recordCollection(orderId, lineId)` | Change a `Ready` line to `Collected`. |
| `recordCustomerDecision(orderId, lineId, decision, decisionReason)` | Change a `BeingMade` or `Ready` line to `Cancelled` or `Substituted`. |

For these operations, its responsibilities include:

1. Receiving the Shop Volunteer's request.
2. Retrieving the order and its lines.
3. Obtaining the signed-in user's identity and the current time for a line change.
4. Asking the order to apply the change to the selected line.
5. Saving an accepted change.
6. Returning the appropriate operation result.

`OrderLine` applies its own transition rules, and `CustomerOrder` recalculates its own status. An order is `Open` while at least one line is not closed. It is `Completed` when all its lines are `Collected`, `Cancelled` or `Substituted`. `Completed` does not mean that any line was collected.

Access is checked before UC-04 starts.

Detailed class responsibilities are documented separately in the CRC Cards.

## 4. Provides and Requires

### Provides

| Component | Purpose |
|---|---|
| `OrderFulfilmentService` | Coordinates viewing orders and changing order-line statuses. |

This slice does not currently provide a shared interface to other slices.

### Requires

| Component | Purpose |
|---|---|
| `CustomerOrderRepository` | Finds orders with their lines, and saves an order and its changed line together. |
| `CurrentUser` | Provides the signed-in user's identity (D-CA2-20). |
| `Clock` | Provides the current date and time for a line's last change. |

The operation inputs and result types are maintained in the operation contracts.

## 5. Integration Boundaries

### Interaction with other slices

- **Reservation Slice:** No direct interaction is currently defined.
- **Offline Transactions Slice:** No direct interaction is currently defined. Offline order changes are not captured by that slice (A-10).
- **Customer Sale Slice:** No direct interaction is currently defined. Recording a line as `Collected` does not record a sale in this design. Any sale-related workflow must use agreed shared contracts.

This slice does not use `StockAvailabilityPort` or `SaleRecordingPort`.

### Shared contract requirements

- The current date and time must come from the shared `Clock` contract.
- The signed-in user's ID must come from the shared `CurrentUser` contract (D-CA2-20). It is not an operation input, and `CurrentUser` does not decide authorisation.
- Expected refusals must be returned as result variants, and technical failures reported as errors (D-CA2-02).
- Error names and meanings must match the shared operation and error catalogue.
- Changes to shared interfaces must be reviewed by affected slice owners before integration.

## 6. Consistency and Failure Handling

A refused change must leave the line status, order status, `decisionReason` and last-change record unchanged.

The expected refusals are:

| Refusal | Condition |
|---|---|
| `OrderNotFound` | No order exists with the supplied `orderId` when viewing an order. |
| `InvalidStatusChange` | The change is not allowed from the line's current status. |
| `ReasonNotSupplied` | A customer decision has no reason and the line is not closed. |

For a customer decision, the line status is checked before the reason.

A technical failure must not leave a partial change. `Recorded(lineStatus, orderStatus)` must not be returned until the change is committed.

An accepted change affects only the selected line and, where required, the order status.

## 7. Related Artefacts

The following documents contain the detailed design information for this slice:

| Artefact | Purpose |
|---|---|
| [use-case.md](use-case.md) | Main success flow, allowed transitions and extensions. |
| [features/order-fulfilment.feature](features/order-fulfilment.feature) | Behavioural scenarios and acceptance examples. |
| [ssd/ssd.puml](ssd/ssd.puml) | System sequence diagram. |
| [contracts/operation-contracts.md](contracts/operation-contracts.md) | Operation inputs, preconditions, postconditions, refusals and failure guarantees. |
| [state/order-line-state.puml](state/order-line-state.puml) | `OrderLine` state machine. |
| [crc/crc.md](crc/crc.md) | Class responsibilities and collaborators. |
| [grasp/grasp.md](grasp/grasp.md) | GRASP design decisions and rejected alternatives. |
| [sequence/view-order.puml](sequence/view-order.puml) | Sequence diagram for `viewOrder`. |
| [sequence/mark-ready.puml](sequence/mark-ready.puml) | Sequence diagram for `markReady`. |
| [sequence/record-collection.puml](sequence/record-collection.puml) | Sequence diagram for `recordCollection`. |
| [sequence/record-customer-decision.puml](sequence/record-customer-decision.puml) | Sequence diagram for `recordCustomerDecision`. |
| [Decision log](../../decisions/decision-log.md) | Design decisions and their review status. |
| [Open questions](../../decisions/open-questions.md) | Unresolved questions, including Q-03, Q-SH-10 and Q-SH-11. |
| [Operation and error catalogue](../../design/operation-error-catalogue.md) | Shared refusal names and expected handling. |
| [Shared interface catalogue](../../design/shared-interface-catalogue.md) | Shared `Clock` and `CurrentUser` contracts. |
