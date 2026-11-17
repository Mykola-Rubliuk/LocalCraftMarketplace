# Slice 3 — UC-10 Reconcile Offline Transactions

**Issue:** #3 · **Backlog:** PB-06 · **Status:** Proposed (scope pending PB-01)
**Traces to:** US-09, FR-13, NFR-05, A-08, A-10, Q-08, Q-09, SC-11–SC-15, D-10–D-12, D-CA2-02, D-CA2-03, D-CA2-04, D-CA2-07

## 1. Scope

UC-10 is assigned to Slice 3 in `docs/scenario-selection.md`, but PB-06 is "pending scope". Confirmation is requested through PB-01 (lecturer scope clarification). Until it is confirmed, this design is treated as proposed.

**In scope:** entering offline sale records after connectivity returns; duplicate and conflict detection; reconciliation into a Sale through SaleRecordingPort; Manager resolution of referred records.

**Out of scope:** the manual offline form itself (outside the system boundary, CA1 dossier 5.6); offline reservations, orders and commission changes (A-10); refunds and payment corrections (BR-05); an automatic offline client or sync engine.

If UC-10 is descoped, this document is kept as an extension appendix and its classes are removed from the integrated class model (PB-07).

## 2. Requirements and offline constraints

| Source | Constraint used in the design |
|---|---|
| FR-13 | Each outage transaction has a unique offline reference and a reconciliation status; an authorised user reconciles it; duplicates and conflicts are flagged for the Manager |
| NFR-05 | No offline transaction remains unaccounted for |
| A-08 | Coordinator records, enters and reconciles; Manager resolves |
| A-10 | Only sales are captured offline; stock movements are entered later with their actual date |
| D-CA2-07 | Duplicates and conflicts never create a Sale |
| UC-10 E1 | Incomplete form data is rejected and nothing is stored |
| UC-10 E2 | Records already stored remain awaiting reconciliation after a connection loss |

Derived rules:
- **C1** An offline transaction is not a Sale; a Sale exists only after reconciliation.
- **C2** A repeated offline reference is a possible duplicate (SC-13).
- **C3** An item already sold, or under an active reservation, is a conflict (SC-14, UC-10 A2).
- **C4** All lines are checked before any sale is recorded; if any line conflicts, the whole transaction is referred (atomic sale).
- **C5** Every record ends as Reconciled or Resolved.

## 3. Classes and responsibilities (CRC / GRASP)

| Class | Responsibilities | Collaborators | GRASP |
|---|---|---|---|
| OfflineReconciliationService | Handle `enterOfflineTransaction`, `reconcile`, `resolve`; check role; coordinate the flow | OfflineTransactionRepository, ConflictChecker, SaleRecordingPort, Clock | Controller (D-CA2-01), Pure Fabrication |
| OfflineTransaction | Know reference, date, lines, recorder, status, reason, saleId, decision and note; enforce allowed status transitions | OfflineLine | Information Expert |
| OfflineLine | Know itemCode and offline price | — | Value object |
| ConflictChecker | Detect duplicate reference; check every line for sold / reserved / unknown items; no side effects | OfflineTransactionRepository, StockAvailabilityPort | Pure Fabrication, High Cohesion |
| OfflineTransactionRepository | Store and find offline transactions | — | Indirection |
| StockAvailabilityPort (shared) | Report availability of an item code | — | Protected Variations (D-CA2-03) |
| SaleRecordingPort (Slice 4) | Record an atomic sale, mark items sold, attribute makers | — | Protected Variations (D-CA2-04) |
| Clock | Provide current date/time | — | Protected Variations |

The Service creates OfflineTransaction (Creator: it holds the initialising data). Slice 3 never creates Sale or SaleLine objects and never changes stock directly (Low Coupling).

Status values: `AwaitingReconciliation`, `Reconciled`, `ReferredToManager`, `Resolved`.
Referral reasons: `DuplicateReference`, `ItemAlreadySold`, `ItemReserved`, `ItemUnknown`, `SaleRejected`.
Manager decisions: `Accepted`, `Adjusted`, `Rejected`, `FollowUpOutsideSystem`.

## 4. Recording offline transactions

**Operation:** `enterOfflineTransaction(submissionId, offlineRef, date, items, prices)`

**Contract — enterOfflineTransaction**
- **Pre:** user is an authorised Market Coordinator.
- **Post (new reference):** an OfflineTransaction was created with a new internal entryId, recordedBy and recordedAt (Clock); status = AwaitingReconciliation.
- **Post (reference already used by another record):** an OfflineTransaction was created; status = ReferredToManager, reason = DuplicateReference; no Sale was recorded.
- **Post (submissionId already processed):** no new record; the existing record and its status are returned (retry, see 6).
- **Refusal (incomplete data, E1):** nothing is stored; the result lists every missing or invalid field (missing reference or date, no items, item without price, negative price, date after today).

The duplicate is checked at entry because SC-13 flags the reference when it is *entered* again. Each record has an internal **entryId**, because the duplicate entry must itself be stored as referred; the offline reference cannot be the storage key.

## 5. Duplicate references

| Case | Result |
|---|---|
| Reference already Reconciled, entered again (SC-13) | New record ReferredToManager (DuplicateReference) |
| Reference already Awaiting, entered again | New record referred; the first record can still be reconciled |
| Reference already Referred or Resolved, entered again | New record referred |
| Same reference, different items or prices | Still DuplicateReference; Manager compares both records |
| Same submission re-sent after a timeout | Not a duplicate; existing record returned |

The system does not decide whether a repeated reference is a real double entry or a reused number; the Manager decides (A-08).

`reconcile(offlineRef)` acts on the single record with that reference in status AwaitingReconciliation; `resolve(offlineRef, …)` acts on the single record in status ReferredToManager. If more than one record matches, the operation is refused and the record must be selected by entryId (open issue U2).

## 6. Retry and timeout scenarios (Q-SH-02)

| ID | Situation | Behaviour |
|---|---|---|
| R1 | Connection lost while entering forms (E2) | Each entry is saved separately; saved entries stay AwaitingReconciliation; the remaining count is shown |
| R2 | Coordinator re-sends an entry after a timeout | submissionId makes entry idempotent; no false duplicate |
| R3 | `reconcile` repeated after success | Precondition fails; current status Reconciled is returned; no second Sale |
| R4 | SaleRecordingPort times out or is unavailable | No status change; record stays AwaitingReconciliation; Coordinator retries later |
| R5 | Retry after an unknown outcome | entryId is sent as idempotency key; SaleRecordingPort returns the existing saleId instead of recording a second Sale |
| R6 | StockAvailabilityPort does not answer | Treated as technical failure; no status change; "no answer" is never treated as "available" |

A record is marked Reconciled only after a confirmed saleId. Retries are manual; automatic retry is out of scope.

## 7. Reconciliation and conflict handling

**Contract — reconcile(offlineRef)**
- **Pre:** exactly one record with offlineRef has status AwaitingReconciliation; user is an authorised Market Coordinator.
- **Post (clean):** a Sale was recorded through SaleRecordingPort with all lines; the record is linked to the sale (saleId); status = Reconciled; the items are no longer available (done by SaleRecordingPort).
- **Post (duplicate or conflict):** no Sale was recorded and no line was sold; status = ReferredToManager with reason.
- **Post (technical failure):** no state change (R4, R6).

Conflict rules (all lines are checked before SaleRecordingPort is called):

| Check | Reason |
|---|---|
| Another record has the same offline reference | DuplicateReference |
| Any item is sold | ItemAlreadySold |
| Any item has an active reservation (an offline sale has no customer, so any active reservation belongs to another customer) | ItemReserved |
| Item code not found | ItemUnknown |
| SaleRecordingPort refuses the sale (e.g. item sold in the shop after the check) | SaleRejected |

**Contract — resolve(offlineRef, decision, note)**
- **Pre:** exactly one record with offlineRef has status ReferredToManager; user is an authorised Manager; decision present; note not blank.
- **Post:** decision, note, resolvedBy and resolvedAt (Clock) recorded; status = Resolved; no Sale is recorded by this operation (SC-15, BR-05; open issue U3).

**Status transitions:**
- enter [new reference] → AwaitingReconciliation
- enter [repeated reference] → ReferredToManager
- AwaitingReconciliation → Reconciled (clean) or ReferredToManager (conflict)
- ReferredToManager → Resolved
- Any other transition is refused. NFR-05 is met when no record is AwaitingReconciliation or ReferredToManager.

## 8. Interaction with SaleRecordingPort

Proposed request (to be frozen with Slice 4 under PB-02):

| Field | Value |
|---|---|
| idempotencyKey | OfflineTransaction.entryId |
| channel | OfflineMarket |
| saleDate | Actual date from the offline form |
| recordedBy | Market Coordinator |
| sourceRef | Offline reference (traceability) |
| lines | itemCode, offline price |

Result variants (D-CA2-02): `Recorded(saleId)` → mark Reconciled; `Rejected(reason)` → refer to Manager (SaleRejected). A technical failure is an error, not a result, and causes no state change.

Rules: called only from `reconcile` after a clean check; called once per successful reconciliation, with the same key on retry; `resolve` does not call the port.

**Fallback:** if Slice 4 is not ready, `RecordingSaleRecorder` (fake) implements the port: it stores calls, returns SALE-1, SALE-2…, honours the idempotency key and marks items sold in `InMemoryStockAvailability` (D-CA2-08).

## 9. Consistency with stock and sale contracts

| ID | Check | Owner |
|---|---|---|
| K1 | SaleRecordingPort marks items sold; Slice 3 only reads availability | Slice 4 / group |
| K2 | SaleRecordingPort re-checks availability and returns Rejected instead of double-selling (gap between check and sale) | Slice 4 |
| K3 | Availability values match the shared StockAvailabilityPort: available, sold, reserved (active reservation), unknown | Group (D-CA2-03) |
| K4 | Sale contract accepts a past sale date (A-10) | Slice 4 |
| K5 | Sale contract accepts the offline price from the form | Slice 4 |
| K6 | Maker attribution (BR-01) is done by Slice 4 from itemCode | Slice 4 |
| K7 | Sale contract supports an idempotency key (Q-SH-02) | Slice 4 |
| K8 | Business refusal = result variant; technical failure = error (D-CA2-02) | Group |
| K9 | One item code = one physical unit (Q-02) | Group |

The fakes run the same contract tests as the real ports, so they cannot drift.

## 10. Diagrams

- `diagrams/ssd-uc10.puml` — system sequence diagram
- `diagrams/state-offline-transaction.puml` — reconciliation status
- `diagrams/sequence-reconcile.puml` — reconcile interaction
- `diagrams/class-slice3.puml` — slice design classes

## 11. Test plan

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
| Recorder times out, then retry | Still Awaiting after timeout; one sale after retry |
| Recorder refuses | ReferredToManager (SaleRejected) |
| Wrong role for reconcile / resolve | Refused |
| NFR-05 full run | No Awaiting or Referred records remain |

**Demo route:** runner or Gherkin run on fakes — clean (OFF-03), duplicate (OFF-03 again), conflict (OFF-04 on sold CER-105), Manager resolution (OFF-04 rejected, "item already sold in the shop").

## 12. Scope assumptions

- S1 UC-10 is in CA2 scope — pending PB-01.
- S2 Only sales are captured offline (A-10).
- S3 The offline form is a manual procedure outside the system.
- S4 Coordinator enters and reconciles; Manager resolves (A-08).
- S5 Refunds and payment corrections are outside the system (BR-05).
- S6 Retries are manual.

## 13. Unresolved issues

| ID | Issue | Proposal | Ask |
|---|---|---|---|
| U1 | Is UC-10 in CA2 scope? | — | Lecturer (PB-01) |
| U2 | Select records by offline reference or by entryId? | Reference, single match per status; entryId when ambiguous | Group |
| U3 | Does an Accepted or Adjusted decision record a sale? | No, decision only | Manager (Q-08) |
| U4 | Does any active reservation count as a conflict? | Yes | Group (Q-08, Q-SH-01) |
| U5 | Does SaleRecordingPort support idempotency key, past date and form price? | Yes, required | Slice 4 (K4, K5, K7) |
| U6 | How are offline references kept unique on paper forms? | Numbered forms per market and coordinator | Q-08, Q-09 |
| U7 | May a Volunteer enter offline records if assigned? | No, unless the Manager assigns it | Q-09 |

