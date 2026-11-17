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

## Decision status vocabulary
Draft = suggested; Accepted = explicitly agreed by group; Rejected = group declined; Superseded = replaced by a later decision.