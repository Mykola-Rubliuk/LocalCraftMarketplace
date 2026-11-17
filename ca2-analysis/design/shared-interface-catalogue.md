# Shared interface and integration catalogue

These are proposed design contracts.A slice may create its own in-memory fake, but the fake must pass the same shared contract tests.

## SaleRecordingPort

**Provider:** Slice 4 — Process a Customer Sale (UC-01)

**Implementation:** `SaleService`

**Purpose:**

Provides a shared entry point for other slices to request the recording of a customer sale without depending on the internal implementation of Slice 4.

### Operation

`recordSale(SaleRequest request)`

### Request

The request contains:

- `processedBy` — identifier of the staff member or authorised processor.
- `customerRef` — optional customer reference.
- `lines` — one or more sale line requests.

Each sale line contains:

- `itemCode`
- `quantity`
- `soldPrice`

### Response

The operation returns a `SaleRecordingResult`.

A successful result provides the unique `saleRef`.

A rejected result provides an agreed error code explaining why the sale could not be recorded.

### Failure and Consistency

If sale recording fails, the provider must return an agreed failure result.

The operation must not leave partially committed sale records or stock changes.

The transaction and rollback mechanism must be defined by the provider and agreed during integration.

### Integration Constraints

- The interface signature must remain consistent across all consuming slices.
- Changes to request fields or result types must be communicated to affected slice owners.
- Reservation ownership and duplicate request handling remain subject to the relevant open questions.
- Offline reconciliation must not mark a transaction as reconciled until successful sale recording is confirmed.