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
| D-CA2-13 | Resolve records the Manager's decision and note only; it does not record a sale | Accepted decision posts the sale | SC-15 and BR-05: corrections happen outside the system | Proposed; confirm through Q-08 |
| D-CA2-14 | Clarify `A-04`: the customer approves offstage; the Shop Volunteer records the decision, which the system does not verify; each `OrderLine` records who made the last change and when | Keep `approvalEvidence`; add a `customerApproved` flag; require Manager approval of each substitution, cancellation and collection; keep a full change history | Evidence cannot be verified in the design; a flag restates a customer's request and adds no information beyond the act of recording; Manager approval would move the Volunteer's work to the Manager; a last-change record gives accountability without a full history (`FR-07`, `R-04`) | Draft, 2026-11-23, Maryna Tarasova; proposed resolution of `Q-03`; test `without approval is rejected` is dropped; limitation: only the last change is attributed; residual risk of `R-04`: a recorded decision is not verified; affects `UC-04` main flow (step 5) and success guarantee, class diagram, sequences and `Q-03`; group review required |
| D-CA2-15 | Record customer's `decisionReason` as mandatory, chosen from one predefined list of values, shared by substitution and cancellation, that includes `NotGiven`  | Drop `decisionReason` entirely; keep `approvalEvidence`; make `decisionReason` optional (blank allowed)  | Replaces `approvalEvidence`; a decision reason gives analysable data on why `OrderLine` was substituted or cancelled; customer does not always give a reason, so `NotGiven` is a valid value and only a decision with no value chosen is rejected; mandatory with `NotGiven` separates "customer gave no reason" from "not recorded", which a blank cannot; one shared list keeps the model simple | Draft, 2026-11-23, Maryna Tarasova; extension beyond the CA1 baseline; tests `rejected when no reason chosen` and `NotGiven accepted` added; group review required  |
| D-CA2-16 | Allow the Manager to restore an `OrderLine` to its previous status, one step back, with `revertLineStatus` (a future extension)  | No revert; allow the Manager explicitly to change `OrderLine` status | Restores only the last state the line has already legitimately held; explicit status setter would allow illegal combinations; deferred to keep Slice 2 within CA2 scope | Draft, 2026-11-23, Maryna Tarasova; extension beyond the CA1 baseline; `UC-04` unchanged for now; the extension adds the Manager as a primary actor, `OrderLine` keeps `previousStatus`, the original `decisionReason` is kept and marked as corrected; reverting a closed line (`Collected`, `Cancelled` or `Substituted`) in a `Completed` order reopens the order; a revert overwrites the last-change record (D-CA2-14) with the Manager and the revert time, so the original change's author is no longer shown; limitation: only one step back; tests `rejected for non-Manager` and `rejected when nothing to revert` planned; group review required |
| D-CA2-17 | Allow the Manager to add, archive and restore values in the `decisionReason` list, except essential ones, which cannot be archived (a future extension); the extension adds an active flag, and new decisions accept only active values, while old `OrderLine`s keep their archived ones; for now the list is predefined and `decisionReason` is modelled as a concept without the flag | Fixed predefined set of `decisionReason` values; free-text `decisionReason`  | Lets the business adjust `decisionReason` values over time; archiving instead of deleting keeps a valid `decisionReason` on old `OrderLine`s; essential values stay untouched; free text is harder to analyse than a predefined list; deferred to keep Slice 2 within CA2 scope | Draft, 2026-11-23, Maryna Tarasova; extension beyond the CA1 baseline; essential values (for example `NotGiven`) are to be defined in the domain model and glossary, and the active flag is deferred to the extension; tests `rejected duplicate reason` and `rejected archiving essential reason` planned; group review required |
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