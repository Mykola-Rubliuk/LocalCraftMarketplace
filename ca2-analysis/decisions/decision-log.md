# Architecture and analysis decision log

| ID | Decision / proposal | Alternatives considered | Rationale | Consequence / status |
|---|---|---|---|---|
| D-CA2-01 | Use application services as use-case controllers | Put all logic in entities; use one generic controller | Keeps actor interaction coordination separate from entity invariants | Proposed; group review required |
| D-CA2-02 | Use explicit result variants for expected refusals | Generic exceptions for all outcomes | Makes business rejection visible in contracts and sequences | Proposed |
| D-CA2-03 | Use shared StockAvailabilityPort | Each slice defines independent stock semantics | Avoids inconsistent availability rules across reservations, sales and offline reconciliation | Proposed; must be frozen by group |
| D-CA2-04 | SaleService provides SaleRecordingPort | Slice 3 directly constructs Sale objects | Preserves one authoritative sale validation and recording path | Proposed |
| D-CA2-05 | Reservation expiry comes from ReservationPolicy | Hard-code three working days in service | CA1 treats duration as uncertain; policy must be confirmed | Proposed; no duration accepted as fact |
| D-CA2-06 | OrderLine owns independent fulfilment status | Single status on CustomerOrder | Supports partial readiness/collection across makers | Supported by scenario evidence; group ratification required |
| D-CA2-07 | Offline conflicts do not create a sale | Best-effort posting and manual correction later | Avoids double-selling or duplicate recording | Proposed; Manager resolution process needs confirmation |
| D-CA2-08 | Slice fakes implement the shared port contracts | Each fake behaves independently | Enables consistent slice tests before integration | Proposed |
| D-CA2-09 | Store each offline entry with an internal entryId; the offline reference is not the storage key | Use offlineRef as the key | A repeated reference must itself be stored as referred to the Manager (SC-13) | Proposed; Slice 3 |
| D-CA2-10 | Check duplicate references at entry and at reconciliation | Check only at reconciliation | SC-13 flags the duplicate when the reference is entered again | Proposed; Slice 3 |
| D-CA2-11 | Check all lines before calling SaleRecordingPort; refer the whole offline transaction if any line conflicts | Record clean lines and refer the rest | Keeps the sale atomic and avoids partial postings | Proposed; Slice 3 |
| D-CA2-12 | Use entryId as idempotency key for recordSale and submissionId for idempotent entry | No idempotency; rely on status checks only | Retries after a timeout must not create a second sale or a false duplicate (Q-SH-02) | Proposed; needs Slice 4 agreement |
| D-CA2-13 | resolve records the Manager's decision and note only; it does not record a sale | Accepted decision posts the sale | SC-15 and BR-05: corrections happen outside the system | Proposed; confirm through Q-08 |

## Shared contract conventions proposed for review

- Stock status values: `Available`, `Reserved`, `Sold`, `Unknown`.
- Sale result: `Recorded(saleRef)` or `Rejected(reason)`.
- Sale request: stable `idempotencyKey`, processor, channel, optional customer reference, sale date where required, optional source reference and all sale lines.
- Slice 3 uses `entryId` as idempotency key, `OfflineMarket` as channel, form date as `saleDate` and `offlineRef` as `sourceRef`.
- Slice 3 reads stock but does not mutate stock or create Sale/SaleLine.
- Slice 4 is the only provider of SaleRecordingPort and owns sale recording and stock updates.

## Agreed shared contract conventions

- Stock status values: `Available`, `Reserved`, `Sold`, `Unknown`.
- Sale result: `Recorded(saleRef)` or `Rejected(reason)`.
- Technical failures are reported separately and do not confirm a sale.
- Sale request contains a stable `idempotencyKey`, `processedBy`,
  `channel`, optional `customerRef`, `saleDate` where required,
  optional `sourceRef` and all sale lines.
- Slice 3 uses `entryId` as idempotency key, `OfflineMarket`
  as channel, form date as `saleDate` and `offlineRef` as `sourceRef`.
- Slice 3 reads stock but does not mutate stock or create Sale/SaleLine.
- Slice 4 is the only provider of SaleRecordingPort and owns
  sale recording and stock updates.
- All four slices use `Clock.now()` for time-dependent operations.
- Reservation working-day calculations belong to `ReservationPolicy`.
- Slice 2 maintains independent order-line fulfilment statuses.
- CustomerOrder status is derived from its order lines.
- Substitution and cancellation require a predefined `decisionReason`.
- `NotGiven` is a valid decision reason.
- Customer approval occurs offstage.
- Successful order-line changes retain the last-change author and timestamp.

## Decision status vocabulary

- **Accepted:** included in the agreed CA2 design scope.
- **Deferred:** intentionally excluded from the current scope
  and retained as a future extension.
- **Rejected:** not adopted.
- **Superseded:** replaced by a later decision.