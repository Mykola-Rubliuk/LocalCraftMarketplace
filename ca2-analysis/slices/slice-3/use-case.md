# UC-10 Reconcile Offline Transactions

| Field | Value |
|---|---|
| **Primary actor** | Market Coordinator |
| **Supporting actor** | Manager, for duplicate or conflicting records |
| **Stakeholders and interests** | Coordinator: enter forms quickly and safely. Manager: every sale accounted for, problems visible. Makers: offline sales attributed to them (BR-01). |
| **Goal** | Bring sales captured during an internet outage into the system record without losing or double-counting any of them |
| **Trigger** | Connectivity has returned and completed offline forms exist |
| **Preconditions** | Coordinator is authorised; each form has an offline reference; the system is available |
| **Success postconditions** | Every entered offline transaction is either Reconciled (Sale recorded, availability updated) or ReferredToManager with its reason; referred records end as Resolved |
| **Failure postconditions** | No Sale is recorded for a refused, duplicate or conflicting entry; entries already stored remain AwaitingReconciliation |
| **Traces to** | US-09, FR-13, NFR-05, A-08, A-10, SC-11–SC-15 |

## Main success scenario

1. Coordinator selects a completed offline form.
2. Coordinator enters the offline reference, date, items and prices.
3. System validates the data and records an OfflineTransaction with status AwaitingReconciliation.
4. Coordinator asks the system to reconcile the offline transaction.
5. System checks the offline reference for duplicates and every item against sold items and active reservations.
6. System reports that no problem was found.
7. System records the Sale through SaleRecordingPort, links it to the offline transaction and marks it Reconciled.
8. Coordinator repeats for the remaining forms; the system shows how many records are still awaiting reconciliation.

## Alternative flows

**A1 — Duplicate reference at entry (from step 3):** The offline reference is already used by another record. System stores the entry as ReferredToManager with reason DuplicateReference; no Sale is recorded.

**A2 — Item conflict (from step 5):** An item is already sold, has an active reservation or is unknown. System records no Sale, sells no line and marks the record ReferredToManager with the reason.

**A3 — Sale refused by SaleRecordingPort (from step 7):** The item was sold after the check. System marks the record ReferredToManager with reason SaleRejected.

**A4 — Manager resolution (after A1, A2 or A3):** Manager reviews the referred record, records a decision and a note; system marks it Resolved. Refunds and payment corrections are handled outside the system (BR-05).

## Exception flows

**E1 — Incomplete form data (from step 2):** System refuses the entry, stores nothing and lists the missing or invalid fields. Coordinator corrects it from the form or refers an unreadable form to the Manager.

**E2 — Connection lost during entry or reconciliation:** Entries already stored remain AwaitingReconciliation. If the outcome of a sale call is unknown, the Coordinator retries; the idempotency key prevents a second Sale.

**E3 — Same entry re-sent after a timeout:** The submissionId is recognised; the existing record is returned and no duplicate is created.

## Business rules and assumptions

- A repeated offline reference is a possible duplicate.
- An item already sold, or under an active reservation, is a conflict.
- Duplicates and conflicts record no Sale and go to the Manager (D-CA2-07).
- All lines are checked before any sale is recorded (atomic sale, D-CA2-11).
- Nothing stays unaccounted for (NFR-05).
- BR-01, BR-05, A-08 and A-10 remain proposed (Q-08, Q-09).