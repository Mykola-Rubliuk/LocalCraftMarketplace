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

## Decision status vocabulary
Draft = suggested; Accepted = explicitly agreed by group; Rejected = group declined; Superseded = replaced by a later decision. Add date and participants when decisions are actually made.
