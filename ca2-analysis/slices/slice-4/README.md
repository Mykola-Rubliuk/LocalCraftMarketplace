# Slice 4 — Process a Customer Sale (UC-01)

**Working owner:** Mykola Rubliuk.

**Links:** US-05, FR-01, FR-04, FR-10, BR-01, Q-06, SC-07.

**Controller / Provider:** `SaleService`

**Shared interface provided:** `SaleRecordingPort`

## 1. Purpose

This slice is responsible for processing customer sales for the Local Craft Marketplace.

It allows an authorised Shop Volunteer to record a sale containing one or more items while maintaining accurate sales records, stock availability and maker attribution.

The slice coordinates the sale-recording process but does not own product catalogue management, reservations, customer orders or offline transaction reconciliation.

## 2. Scope

### In scope

- Accept a customer sale request.
- Validate the sale request and its individual lines.
- Retrieve product information and maker attribution.
- Check stock availability.
- Coordinate the creation of a Sale and its SaleLines.
- Request stock updates for successfully sold items.
- Return a success or failure result through the shared interface.
- Maintain all-or-nothing sale-processing behaviour.

### Out of scope

- Creating and maintaining product records.
- Managing customer reservations.
- Managing customer orders and partial fulfilment.
- Managing maker commissions.
- Reconciling offline market transactions.

These responsibilities belong to other project areas or require separate agreement.

## 3. Main Responsibilities

`SaleService` coordinates the customer sale workflow.

Its responsibilities include:

1. Receiving requests through `SaleRecordingPort`.
2. Checking that the processor is authorised.
3. Validating the requested sale lines.
4. Obtaining product and maker information.
5. Checking item availability.
6. Coordinating sale and sale-line recording.
7. Requesting stock status updates.
8. Returning the appropriate operation result.

Detailed class responsibilities are documented separately in the CRC Cards.

## 4. Provides and Requires

### Provides

| Component | Purpose |
|---|---|
| `SaleService` | Coordinates the customer sale workflow. |
| `SaleRecordingPort` | Provides a shared entry point for other components to request sale recording. |

### Requires

| Component | Purpose |
|---|---|
| `SaleRepository` | Persists sale and sale-line records. |
| `StockAvailabilityPort` | Checks and updates stock availability. |
| `ProductCatalogue` | Provides product information and maker attribution. |
| `Clock` | Provides the current date and time for sale recording. |
| `ProcessorAuthorisationPort` | Confirms that the `processedBy` identifier in a `SaleRequest` belongs to an authorised Shop Volunteer or Market Coordinator. |

The exact method signatures and result types are maintained in the shared interface and operation contract documents.
## 5. Integration Boundaries

### Interaction with other slices

- **Reservation Slice:** Provides stock availability information. Reservation ownership must be resolved before allowing a sale of an item reserved by the same customer.
- **Customer Order Slice:** Must use agreed shared contracts if an order-related workflow needs to interact with sale recording.
- **Offline Transactions Slice:** May depend on sale-recording functionality when reconciling offline transactions, subject to the agreed integration design.

### Shared contract requirements

- Item identification must be consistent across all slices.
- Stock availability operations must use the agreed shared interface.
- Sale results and error conventions must be compatible with the shared design.
- Changes to shared interfaces must be reviewed by affected slice owners before integration.

## 6. Consistency and Failure Handling

The sale operation must follow an all-or-nothing approach.

If any requested line is invalid or unavailable, the entire sale must be rejected.

A failure during persistence or stock updating must not leave partially committed sale records or stock changes.

The technical transaction and rollback mechanism must be agreed and documented separately in the technical design notes.

## 7. Related Artefacts

The following documents contain the detailed design information for this slice:

| Artefact | Purpose |
|---|---|
| `design/operation-contract.md` | Operation signature, preconditions, postconditions and failure guarantees. |
| `design/crc-cards.md` | Class responsibilities and collaborators. |
| `design/operation-error-catalogue.md` | Error definitions and expected handling. |
| `design/shared-interface.md` | Shared interface definitions and method signatures. |
| `design/design-notes.md` | Technical decisions, transaction handling and rollback considerations. |
| `design/` Slice 4 Gherkin feature file | Behavioural scenarios and acceptance evidence. |
| `design/design-class-diagram.md` | Structural relationships and class design, once agreed. |
