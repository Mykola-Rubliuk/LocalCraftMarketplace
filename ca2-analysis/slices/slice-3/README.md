# Slice 3 — UC-10 Reconcile Offline Transactions

**Owner:** Bohdan Byrdin · **Issue:** #3 · **Backlog:** PB-06 · **Status:** Proposed (scope pending PB-01)
**Traces to:** US-09, FR-13, NFR-05, A-08, A-10, Q-08, Q-09, SC-11–SC-15, D-10–D-12, D-CA2-02, D-CA2-03, D-CA2-04, D-CA2-07, D-CA2-09–D-CA2-13

## Artefacts

| Artefact | File |
|---|---|
| Use case | [use-case.md](use-case.md) |
| Gherkin | [features/offline-reconciliation.feature](features/offline-reconciliation.feature) |
| System sequence diagram | [ssd/ssd.puml](ssd/ssd.puml) |
| Operation contracts | [contracts/operation-contracts.md](contracts/operation-contracts.md) |
| Status state diagram | [contracts/state.puml](contracts/state.puml) |
| CRC cards | [crc/crc.md](crc/crc.md) |
| Slice class diagram | [crc/class-diagram.puml](crc/class-diagram.puml) |
| GRASP justification | [grasp/grasp.md](grasp/grasp.md) |
| Sequence diagram (reconcile) | [sequence/sequence.puml](sequence/sequence.puml) |

## Scope

UC-10 is assigned to Slice 3 in `docs/scenario-selection.md`; PB-06 is "pending scope" and confirmation is requested through PB-01.

**In scope:** entering offline sale records after connectivity returns; duplicate and conflict detection; reconciliation into a Sale through SaleRecordingPort; Manager resolution.
**Out of scope:** the manual offline form (outside the system boundary); offline reservations, orders and commission changes (A-10); refunds and payment corrections (BR-05); an automatic offline client or sync engine.

If UC-10 is descoped, this slice is kept as an extension appendix and removed from the integrated class model (PB-07).

## Provides / requires

- **Provides:** OfflineReconciliationService
- **Requires:** OfflineTransactionRepository, StockAvailabilityPort (shared, D-CA2-03), SaleRecordingPort (Slice 4, D-CA2-04), Clock
- **Fakes:** InMemoryOfflineTransactionRepository, InMemoryStockAvailability, RecordingSaleRecorder (stores calls, honours the idempotency key, marks items sold in the fake stock)

## Retry and timeout (Q-SH-02)

| ID | Situation | Behaviour |
|---|---|---|
| R1 | Connection lost while entering forms (E2) | Each entry is saved separately; saved entries stay AwaitingReconciliation |
| R2 | Entry re-sent after a timeout | submissionId makes entry idempotent; no false duplicate |
| R3 | reconcile repeated after success | Precondition fails; status Reconciled returned; no second Sale |
| R4 | SaleRecordingPort times out | No status change; Coordinator retries later |
| R5 | Retry after an unknown outcome | entryId sent as idempotency key; existing saleId returned, no second Sale |
| R6 | StockAvailabilityPort does not answer | Technical failure; no status change; never treated as "available" |

A record is marked Reconciled only after a confirmed saleId. Retries are manual.

## Interaction with SaleRecordingPort

Proposed request (to be frozen with Slice 4 under PB-02): idempotencyKey = entryId; channel = OfflineMarket; saleDate = actual date on the form; recordedBy = Coordinator; sourceRef = offline reference; lines = itemCode + offline price.

Result variants (D-CA2-02): `Recorded(saleId)` → Reconciled; `Rejected(reason)` → ReferredToManager (SaleRejected). A technical failure is an error and causes no state change. The port is called only from reconcile after a clean check; resolve never calls it.

## Consistency with stock and sale contracts

| ID | Check | Owner |
|---|---|---|
| K1 | SaleRecordingPort marks items sold; Slice 3 only reads availability | Slice 4 / group |
| K2 | SaleRecordingPort re-checks availability and returns Rejected instead of double-selling | Slice 4 |
| K3 | Availability values match the shared port: available, sold, reserved, unknown | Group |
| K4 | Sale contract accepts a past sale date (A-10) | Slice 4 |
| K5 | Sale contract accepts the offline price from the form | Slice 4 |
| K6 | Maker attribution (BR-01) done by Slice 4 from itemCode | Slice 4 |
| K7 | Sale contract supports an idempotency key | Slice 4 |
| K8 | Business refusal = result variant; technical failure = error (D-CA2-02) | Group |
| K9 | One item code = one physical unit (Q-02) | Group |

## Test plan

| Test | Expected result |
|---|---|
| SC-11 enter valid record | AwaitingReconciliation; reference, date, recorder stored |
| SC-12 clean reconcile | One sale; item sold; Reconciled; saleId linked |
| SC-13 reference entered again | New record ReferredToManager (DuplicateReference); still one sale |
| SC-14 item already sold | ReferredToManager (ItemAlreadySold); no sale |
| SC-15 Manager rejects with note | Resolved; decision and note stored; no sale |
| Incomplete form data | Refused; nothing stored; missing fields listed |
| Reconcile same record twice | Second call refused; one sale |
| Item reserved for another customer | ReferredToManager (ItemReserved); no sale |
| Two lines, one sold | ReferredToManager; nothing sold |
| Same submissionId re-sent | Same record returned; no duplicate |
| Recorder times out, then retry | Still Awaiting; one sale after retry |
| Recorder refuses | ReferredToManager (SaleRejected) |
| Wrong role for reconcile / resolve | Refused |
| NFR-05 full run | No Awaiting or Referred records remain |

**Demo route:** runner or Gherkin run on fakes — clean (OFF-03), duplicate (OFF-03 again), conflict (OFF-04 on sold CER-105), Manager resolution (OFF-04 rejected).
**Fallback:** if Slice 4 is not ready, RecordingSaleRecorder stands in for SaleRecordingPort.

## Scope assumptions

- S1 UC-10 is in CA2 scope — pending PB-01.
- S2 Only sales are captured offline (A-10).
- S3 The offline form is a manual procedure outside the system.
- S4 Coordinator enters and reconciles; Manager resolves (A-08).
- S5 Refunds and payment corrections are outside the system (BR-05).
- S6 Retries are manual.

## Unresolved issues

| ID | Issue | Proposal | Ask |
|---|---|---|---|
| U1 | Is UC-10 in CA2 scope? | — | Lecturer (PB-01, Q-SH-08) |
| U2 | Select records by offline reference or entryId? | Reference, single match per status; entryId when ambiguous | Group (Q-SH-05) |
| U3 | Does an Accepted/Adjusted decision record a sale? | No, decision only (D-CA2-13) | Manager (Q-08) |
| U4 | Does any active reservation count as a conflict? | Yes | Group (Q-SH-07) |
| U5 | Does SaleRecordingPort support idempotency key, past date, form price? | Required | Slice 4 (Q-SH-06) |
| U6 | How are offline references kept unique on paper forms? | Numbered forms per market and coordinator | Q-08, Q-09 |
| U7 | May a Volunteer enter offline records if assigned? | No, unless the Manager assigns it | Q-09 |

## Peer review

- [ ] Terms match `docs/glossary.md` and the CA1 baseline
- [ ] Use case, Gherkin, SSD, contracts and sequence agree
- [ ] SC-11–SC-15 each map to a postcondition and a test
- [ ] State transitions match the contracts
- [ ] Ports match the other slices (K1–K9)
- [ ] No path creates a sale for a duplicate or conflict (D-CA2-07)
- [ ] Traceability and PB-06 status updated
- [ ] AI-supported content disclosed; human decisions recorded

**Reviewer:** ______ **Date:** ______ **Comments and disposition:** ______