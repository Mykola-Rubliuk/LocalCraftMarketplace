# Operation contracts — UC-10

Status values: AwaitingReconciliation, Reconciled, ReferredToManager, Resolved.
Referral reasons: DuplicateReference, ItemAlreadySold, ItemReserved, ItemUnknown, SaleRejected.
Manager decisions: Accepted, Adjusted, Rejected, FollowUpOutsideSystem.
Expected refusals are returned as result variants; technical failures are errors (D-CA2-02).

## CO-1 enterOfflineTransaction(submissionId, offlineRef, date, items, prices)

| | |
|---|---|
| **Cross-references** | UC-10 steps 2–3, A1, E1, E3; SC-11, SC-13; FR-13 |
| **Preconditions** | User is an authorised Market Coordinator |
| **Postconditions (new reference)** | An OfflineTransaction was created with a new entryId, submissionId, offlineRef, date, recordedBy and recordedAt (Clock); an OfflineLine was created for each item with its price; status = AwaitingReconciliation |
| **Postconditions (reference already used)** | An OfflineTransaction was created as above; status = ReferredToManager; referralReason = DuplicateReference; no Sale was recorded |
| **Postconditions (submissionId already processed)** | No object was created; the existing record and its status are returned |
| **Refusal (incomplete data)** | Nothing was created; the result lists every missing or invalid field (reference, date, no items, item without price, negative price, date after today) |

## CO-2 reconcile(offlineRef)

| | |
|---|---|
| **Cross-references** | UC-10 steps 4–7, A2, A3, E2; SC-12, SC-14; FR-13, NFR-05 |
| **Preconditions** | Exactly one record with offlineRef has status AwaitingReconciliation; user is an authorised Market Coordinator |
| **Postconditions (clean)** | A Sale was recorded through SaleRecordingPort with all lines, using entryId as idempotency key; tx.saleId = the returned saleId; tx.status = Reconciled; the items are no longer available (done by SaleRecordingPort) |
| **Postconditions (duplicate or conflict)** | No Sale was recorded and no line was sold; tx.status = ReferredToManager; tx.referralReason set |
| **Postconditions (sale refused by port)** | No Sale was recorded; tx.status = ReferredToManager; tx.referralReason = SaleRejected |
| **Technical failure** | No state change; tx remains AwaitingReconciliation |

## CO-3 resolve(offlineRef, decision, note)

| | |
|---|---|
| **Cross-references** | UC-10 A4; SC-15; A-08, BR-05 |
| **Preconditions** | Exactly one record with offlineRef has status ReferredToManager; user is an authorised Manager; decision present; note not blank |
| **Postconditions** | tx.decision, tx.resolutionNote, tx.resolvedBy and tx.resolvedAt (Clock) were set; tx.status = Resolved; no Sale was recorded (D-CA2-13) |
