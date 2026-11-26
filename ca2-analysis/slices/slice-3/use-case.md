# UC-10 Reconcile Offline Transactions

| Field | Value |
|---|---|
| **Primary actor** | Market Coordinator |
| **Supporting actor** | Manager, for referred entries |
| **Stakeholders and interests** | Coordinator: enter forms quickly and retry safely. Manager: every sale accounted for, problems visible. Makers: offline sales attributed to them (BR-01). |
| **Goal** | Bring sales captured during an internet outage into the system record without losing or double-counting any of them |
| **Trigger** | Connectivity has returned and completed offline forms exist |
| **Preconditions** | Coordinator is authorised; each form has an offline reference; the system is available |
| **Success postconditions** | Every entered offline transaction is either `Reconciled` (sale recorded, `saleRef` stored) or `ReferredToManager` with its reason; referred entries end as `Resolved` |
| **Failure postconditions** | No sale is recorded for a refused, duplicate or conflicting entry; after a technical failure the entry remains `AwaitingReconciliation` |
| **Traces to** | US-09, FR-13, NFR-05, A-08, A-10, SC-11–SC-15 |

## Main success scenario

1. Coordinator selects a completed offline form.
2. Coordinator enters the submission, offline reference, sale date and lines (item code, quantity, sold price).
3. System validates the data, creates an `OfflineTransaction` with a new `entryId` and status `AwaitingReconciliation`, and returns the entry.
4. Coordinator asks the system to reconcile the entry by `entryId`.
5. System creates the `SaleRequest` for the entry and stores it on the entry.
6. System asks `SaleRecordingPort` whether a sale was already recorded for this request; none is found.
7. System checks the offline reference for duplicates and every line's stock status; no problem is found.
8. System records the sale through `SaleRecordingPort`, stores the returned `saleRef` and marks the entry `Reconciled`.
9. Coordinator repeats for the remaining entries; the system shows how many are still awaiting reconciliation.

## Alternative flows

**A1 — Duplicate reference at entry (from step 3):** Another entry already uses the offline reference. System stores the new entry as `ReferredToManager` with reason `DuplicateReference`; no sale is recorded.

**A2 — Sale already recorded (from step 6):** A previous attempt recorded the sale but its response was lost. System stores the original `saleRef` and marks the entry `Reconciled` without new checks or a second sale.

**A3 — Item conflict (from step 7):** An item is `Sold`, `Reserved` or `Unknown`. System records no sale, sells no line and marks the entry `ReferredToManager` with the reason.

**A4 — Sale rejected (from step 6 or 8):** `SaleRecordingPort` returns `Rejected(reason)`, including `IdempotencyKeyConflict` or a stock change after the check. System marks the entry `ReferredToManager` with reason `SaleRejected` and the underlying reason as detail.

**A5 — Manager resolution (after A1, A3 or A4):** Manager selects the referred entry by `entryId`, records a `ResolutionDecision` and a note; system marks it `Resolved`. No sale is recorded; refunds and payment corrections are handled outside the system (BR-05).

**A6 — Same submission re-sent (from step 3):** The `submissionId` is already stored. System returns the existing entry and creates nothing.

## Exception flows

**E1 — Incomplete form data (from step 2):** System refuses the entry with `InvalidOfflineEntry`, stores nothing and lists the invalid fields.

**E2 — Technical failure (steps 5–8):** Persistence, stock service or sale recording fails or times out. The entry remains `AwaitingReconciliation` with its stored `SaleRequest`. The Coordinator retries later; the same request and idempotency key are reused, so no second sale can be recorded.

**E3 — Unauthorised user:** A non-Coordinator entering or reconciling, or a non-Manager resolving, is refused; nothing changes.

## Business rules

- A repeated offline reference is a possible duplicate.
- An item that is Sold, Reserved or Unknown is a conflict.
- Duplicates and conflicts record no sale and go to the Manager.
- All lines are checked before any sale is recorded; the sale is all-or-nothing.
- Only `Recorded(saleRef)` permits `Reconciled`.
- Nothing stays unaccounted for (NFR-05).
