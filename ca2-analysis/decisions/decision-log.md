# Architecture and analysis decision log

This log records design choices represented in the CA2 artefacts, planned work and deferred extensions. Modelled describes design evidence, not implemented code or formal group approval.

| ID | Decision / proposal | Alternatives considered | Rationale | Consequence / status |
|---|---|---|---|---|
| D-CA2-01 | Use application services as use-case controllers | Put all logic in entities; use one generic controller | Keeps actor interaction coordination separate from entity invariants | Modelled — integrated class diagram; four application services. |
| D-CA2-02 | Use explicit result variants for expected refusals | Generic exceptions for all outcomes | Makes business rejection visible in contracts and sequences | Modelled — operation contracts and error catalogue. |
| D-CA2-03 | Use shared StockAvailabilityPort | Each slice defines independent stock semantics | Avoids inconsistent availability rules across reservations, sales and offline reconciliation | Modelled — shared interface catalogue and integrated class diagram. |
| D-CA2-04 | SaleService provides SaleRecordingPort | Slice 3 directly constructs Sale objects | Preserves one authoritative sale validation and recording path | Modelled — Slice 4 sale contract and shared interface catalogue. |
| D-CA2-05 | Reservation expiry comes from ReservationPolicy | Hard-code three working days in service | CA1 leaves the expiry duration open | Modelled — Slice 1 contract; exact expiry policy remains open (Q-01). |
| D-CA2-06 | OrderLine owns independent fulfilment status | Single status on CustomerOrder | Supports partial readiness/collection across makers | Modelled — Slice 2 CRC, GRASP and state diagram. |
| D-CA2-07 | Offline conflicts do not create a sale | Best-effort posting and manual correction later | Avoids double-selling or duplicate recording | Modelled — Slice 3 CO-2; detailed operational policy remains open (Q-08). |
| D-CA2-08 | Require slice fakes to follow shared port contracts | Each fake behaves independently | Enables consistent slice tests before integration | Planned — shared contract test plan; execution not evidenced. |
| D-CA2-09 | Store each offline entry with an internal entryId; the offline reference is not the storage key | Use offlineRef as the key | A repeated reference must itself be stored as referred to the Manager (SC-13) | Modelled — Slice 3 CO-1. |
| D-CA2-10 | Check duplicate references at entry and at reconciliation | Check only at reconciliation | SC-13 flags the duplicate when the reference is entered again | Modelled — Slice 3 CO-1 and CO-2. |
| D-CA2-11 | Check all lines before a new sale attempt; refer the whole offline transaction if any line conflicts | Record clean lines and refer the rest | Keeps the sale atomic and avoids partial postings | Modelled — Slice 3 CO-2; recovery is checked before conflicts on retries. |
| D-CA2-12 | Use entryId as idempotency key for recordSale and submissionId for idempotent entry | No idempotency; rely on status checks only | Retries after a timeout must not create a second sale or a false duplicate (Q-SH-02) | Modelled — Slice 3 CO-1/CO-2 and Slice 4 OC-4.1/OC-4.2. |
| D-CA2-13 | Resolve records the Manager's decision and note only; it does not record a sale | Accepted decision posts the sale | SC-15 and BR-05: corrections happen outside the system | Modelled — Slice 3 CO-3; related question Q-08. |
| D-CA2-14 | Customer approval occurs offstage; the volunteer records the unverified decision and last-change author/time (`A-04`). | `approvalEvidence`; approval flag; Manager approval; full history | Avoids unverifiable evidence and retains basic accountability (`FR-07`, `R-04`). | Modelled in Slice 2 (draft baseline change) — Maryna Tarasova, 2026-11-23; Q-03 and UC-04 affected; approval not verified; only last change retained. |
| D-CA2-15 | Require a shared predefined `decisionReason` for substitution/cancellation, including `NotGiven`. | No reason; `approvalEvidence`; optional reason | Distinguishes no customer reason from missing data; supports analysis. | Modelled in Slice 2 (draft baseline extension) — Maryna Tarasova, 2026-11-23; missing reason rejected; NotGiven accepted; full list remains open. |
| D-CA2-16 | Future extension: Manager restores one previous line status via `revertLineStatus`. | No revert; unrestricted status changes | Restores a previously valid state without arbitrary transitions. | Deferred — Maryna Tarasova, 2026-11-23; UC-04 unchanged. Future previousStatus, corrected reason, order reopening and last-change attribution; tests planned. |
| D-CA2-17 | Future extension: Manager adds, archives and restores reason values; essential values cannot be archived. | Fixed list; free text | Supports updates while preserving historical reasons. | Deferred — Maryna Tarasova, 2026-11-23; current list predefined; future active flag and essential values; tests planned. |
| D-CA2-18 | Use `CurrentUser.getUserId()` in Slice 2. | Pass `volunteerId` to each operation | Records the signed-in user without adding actor IDs to system operations. | Modelled in Slice 2 (draft) — GRASP and sequence diagrams; shared identity policy remains open. |

## Shared contract conventions

The following conventions describe the current design. Individual decision statuses and limitations are recorded above.

- Stock states: `Available`, `Reserved`, `Sold`, `Unknown`.
- Sale outcomes: `Recorded(saleRef)` or `Rejected(reason)`; technical failures are separate.
- Sale request: stable `idempotencyKey`, `processedBy`, `channel`, optional `customerRef`, `saleDate` where required, optional `sourceRef` and sale lines.
- Slice 3 uses `entryId` as the idempotency key, `OfflineMarket` as channel, form date as `saleDate` and `offlineRef` as `sourceRef`.
- Slice 3 reads stock and delegates sale recording to Slice 4, the sole provider of `SaleRecordingPort` responsible for sale recording and stock updates.
- All slices use `Clock.now()`; `ReservationPolicy` handles working-day calculations.
- Slice 2 tracks independent line statuses; `CustomerOrder` derives its status from its lines.
- Substitution and cancellation require a predefined `decisionReason`, including `NotGiven`.
- Customer approval occurs offstage; successful line changes retain the last-change author and timestamp.

## Decision status vocabulary

- **Modelled:** represented in the current design artefacts. A draft qualifier identifies an unconfirmed baseline or interface decision.
- **Planned:** approach documented; execution not evidenced.
- **Draft / Proposed:** recorded for consideration; not confirmed as accepted.
- **Accepted:** included in the agreed CA2 design scope.
- **Deferred:** outside the current scope; retained as a future extension.
- **Rejected:** not adopted.
