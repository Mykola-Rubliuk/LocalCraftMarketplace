# CA2 Integration Review — Reservation, Offline Reconciliation and Customer Sale

## Review details

| Field | Details |
|---|---|
| Project | Local Craft Marketplace — Kerry Makers Cooperative |
| Original reviewer (Slices 1 and 3) | Mykola Rubliuk |
| Slice 4 review | Self-review + Bogdan Byrdin |
| Review scope | Slice 1 — UC-02 Manage Reservation; Slice 3 — UC-10 Reconcile Offline Transactions; Slice 4 — UC-01 Process Customer Sale (self-review) |
| Overall outcome | Most requested design changes are present; remaining alignment issues are recorded below. |

**Status convention:** `Changed` means the requested design change is visible in the reviewed files; `Changes requested` means a change is missing, incomplete or inconsistent. These are document-level findings, not executed test results or formal peer approval. The ZIP does not establish correcting commit IDs or reviewer sign-off.

## 1. Slice 1 — UC-02 Manage Reservation

**Review outcome:** Substantially changed; remaining consistency issues recorded.

**Artefacts covered:** reservation and expiry interaction diagrams, CRC cards, GRASP decisions, operation contracts and Gherkin scenarios.

### Review findings and requested changes

| ID | Artefact / finding | Required correction | Status | Follow-up evidence |
|---|---|---|---|---|
| IR-S1-01 | `Reserve-Item.puml` — outdated stock operation and incomplete validation signature | Replace `markReserved(itemCode)` with `reserveIfAvailable(itemCode)` and `validateRequest()` with `validateRequest(itemCode, customerRef, conditions)`. | Changed | `Reserve-Item.puml` now uses `reserveIfAvailable(itemCode)` and the complete validation signature. |
| IR-S1-02 | `Reserve-Item.puml` — expiry calculation assigned to the wrong abstraction | Remove `workingDaysBetween()` from Clock. Obtain the current date and time through `Clock.now()` and delegate expiry calculation to `ReservationPolicy.calculateExpiry(currentDateTime)`. | Changed | The reserve interaction calls `Clock.now()` then `calculateExpiry(currentDateTime)`; working-day calculation is assigned to the policy. |
| IR-S1-03 | `Reserve-Item.puml` — confirmation timing | Place `ReservationConfirmed` at the end of the successful execution branch. Complete all validation, stock and persistence checks before confirming success; rejection branches must precede confirmation. | Changed | Confirmation is reachable only after successful repository save and stock reservation; rejection branches do not confirm a reservation. |
| IR-S1-04 | CRC cards — missing or outdated operation responsibilities | Update the cards to reflect the operations and responsibilities listed below, removing working-day calculations from Clock. | Changed | `crc/crc.md` includes all requested operations and separates time access from working-day rules. |
| IR-S1-05 | GRASP decisions — responsibility allocation | Explain the allocation of expiry policy, stock transitions, reservation persistence and time access to ReservationPolicy, StockAvailabilityPort, ReservationRepository and Clock respectively. | Changed | GRASP decisions 3–8 address policy, persistence, stock transitions, Clock and consistency. |
| IR-S1-06 | Operation contracts and Gherkin — failure and boundary coverage | Distinguish `ConflictingReservation` from `ItemUnavailable`. Include `StockUpdateFailed`, `StockServiceUnavailable` and `PersistenceFailed` as technical failure outcomes. Add scenarios covering failed reservation persistence with unchanged stock and expiry where another commitment prevents release. | Changed | `contract.md` distinguishes the two refusals and lists all three technical failures. Gherkin includes failed persistence with unchanged stock and expiry with another commitment. Remaining cross-model result-type issues are listed separately. |

### Original CRC and GRASP alignment requirements

| Class / interface | Operation or responsibility to document |
|---|---|
| ReservationService | `validateRequest(itemCode, customerRef, conditions)` validates reservation request details. |
| ReservationRepository | `findActiveByItemCode()` retrieves an existing active reservation for the selected item; `findAllActive()` retrieves active reservations for expiry evaluation. The repository is responsible for reservation retrieval and persistence. |
| ReservationPolicy | `calculateExpiry(currentDateTime)` calculates expiry according to the reservation policy. Policy calculations belong here rather than in Clock or the application service. |
| StockAvailabilityPort | `reserveIfAvailable()` reserves only available stock; `releaseIfReserved()` releases eligible reserved stock. The shared port encapsulates stock transitions. |
| Clock | `now()` supplies the current date and time through a shared time abstraction, without working-day calculation responsibilities. |

### Additional alignment findings

| ID | Finding and remaining action | Status |
|---|---|---|
| IR-S1-07 | The new `ssd/ssd.puml` exists, and README/use-case files are in the slice root. Both SSD operations are present. | Changed |
| IR-S1-08 | `Reserve-Item.puml` calls `rollbackReservation(reservation)`, which is absent from ReservationRepository in the class diagram and CRC. Align the model or express rollback as a transaction constraint. | Changes requested |
| IR-S1-09 | The SSD and reserve interaction return `Rejected` for technical failures; the class model defines `ReservationTechnicalFailure`. Expiry interaction always returns `ExpiredReservations(list)` even after a failure, unlike the SSD. Align failure signalling and the use-case precedence for active reservations versus unavailable stock. | Changes requested |

## 2. Slice 3 — UC-10 Reconcile Offline Transactions

**Review outcome:** Substantially changed; remaining consistency issues recorded.

**Artefacts covered:** SSD, sequence diagram, SaleRequest construction, sale recovery and idempotency behaviour, CRC cards, GRASP decisions, operation contracts and Gherkin scenarios.

### Review findings and requested changes

| ID | Artefact / finding | Required correction | Status | Follow-up evidence |
|---|---|---|---|---|
| IR-S3-01 | SSD and sequence diagram — outdated identifiers and method signatures | Align the operations, parameters and result identifiers with the integrated class diagram using the mapping below. | Changed | SSD, sequence and contracts use `entryId`, `saleRef`, the shared request and the revised lookup/role/stock names. `recordedBy` is now consistent in the entry operation across the SSD, contract and class model. |
| IR-S3-02 | SaleRequest — cross-slice request structure | Construct the request using the shared SaleRequest fields and line structure specified below. | Changed | The sequence and CO-2 specify the requested fields, with a SaleRequestLine per OfflineLine. Offline lines retain itemCode, quantity and soldPrice; discount is optional and not captured on the offline form. |
| IR-S3-03 | Reconciliation — stock conflict checks before recovery | Persist the original SaleRequest before the first recording attempt and call `findRecordedResult(request)` before duplicate and stock conflict checks. Recover a previously committed `saleRef` rather than referring an already recorded sale to the Manager. | Changed | The sequence and CO-2 persist a stable request before sale processing, recover before conflict checks and mark a recovered sale Reconciled without a new sale. |
| IR-S3-04 | Reconciliation — idempotency and technical failures | Reuse the original request and key after a timeout; reject `IdempotencyKeyConflict`; keep the transaction awaiting reconciliation on technical failure. | Changed | Sequence, CRC, CO-2 and Gherkin reuse the stored request, retain AwaitingReconciliation on technical failure and handle key conflict as a rejected sale referred to the Manager. The existing committed sale must not be interpreted as absent; see additional finding below. |
| IR-S3-05 | CRC cards — missing recovery, lookup and transaction evidence responsibilities | Update the responsibilities and OfflineTransaction attributes listed below. | Changed | All listed methods, recovery responsibilities and OfflineTransaction attributes appear in the CRC cards. |
| IR-S3-06 | GRASP decisions — responsibility allocation | Explain why OfflineReconciliationService coordinates reconciliation and recovery, ConflictChecker detects conflicts, OfflineTransactionRepository handles retrieval and persistence, and SaleRecordingPort isolates reconciliation from sale-recording implementation. | Changed | GRASP table explicitly justifies the four requested responsibility allocations and stable-request creation. |
### Original operation and identifier alignment requirements

Apply these changes to the relevant system or internal interaction messages; internal operations do not require separate system operation contracts.

| Previous operation / identifier | Required operation / identifier |
|---|---|
| `reconcile(offlineRef)` | `reconcile(entryId)` |
| `resolve(offlineRef, decision, note)` | `resolve(entryId, decision, note)` |
| `findByRefAndStatus()` | `findByEntryId()` |
| `availabilityOf(itemCode)` | `getStatus(itemCode)` |
| `requireRole(MarketCoordinator)` | `requireCoordinatorRole()` |
| `saleId` | `saleRef` |
| `recordSale(entryId, saleDate, coordinator, offlineRef, lines)` | `recordSale(request: SaleRequest)` |

### Required shared SaleRequest structure

| Field | Value in offline reconciliation |
|---|---|
| `idempotencyKey` | `entryId` |
| `processedBy` | Authorised coordinator |
| `channel` | `OfflineMarket` |
| `customerRef` | `null` |
| `saleDate` | Original offline transaction date |
| `sourceRef` | `offlineRef` |
| `lines` | Offline transaction lines |

Each sale line must include `itemCode`, `quantity` and `soldPrice`, with an optional `discountAmount`.

### Original CRC and GRASP alignment requirements

| Class / interface | Operation or responsibility to document |
|---|---|
| OfflineReconciliationService | Coordinates reconciliation and sale recovery; creates and reuses SaleRequest; handles reconciliation results. |
| OfflineTransactionRepository | `findByEntryId()` retrieves a unique entry; `findBySubmissionId()` retrieves an existing submission to prevent duplicate entry; `existsOtherWithRef()` detects duplicate offline references. Owns retrieval and persistence responsibilities. |
| SaleRecordingPort | `findRecordedResult(request)` retrieves a previously committed sale result. The port isolates offline reconciliation from the implementation of sale recording. |
| ConflictChecker | `check()` detects duplicate references and stock conflicts. |
| OfflineLine | Stores `itemCode`, `quantity` and `soldPrice`. |
| OfflineTransaction | Retains the accountability, referral, sale and resolution evidence described below. |

Update the OfflineTransaction CRC card to describe `recordedBy`, `referralDetail`, `saleRef`, `saleRequest`, `decision`, `resolutionNote`, `resolvedBy` and `resolvedAt`.

### Additional alignment findings

| ID | Finding and remaining action | Status |
|---|---|---|
| IR-S3-07 | The trusted source of `recordedBy`, `resolvedBy` and the coordinator's `processedBy` remains unspecified. Role checks are named, but the actor identity must be derived from or verified against the signed-in user. Agree the shared identity approach without changing the saved request during retries. | Changes requested |

## 3. Slice 4 — UC-01 Process Customer Sale

**Review type:** Technical self-review and cross-slice integration review.

**Review outcome:** The main design responsibilities and class relationships have been improved. Some minor inconsistencies between the individual slice artefacts and the integrated design remain.

**Artefacts covered:** Use case, SSD, sequence diagram, operation contracts, CRC cards, GRASP decisions, Gherkin scenarios and integrated class diagram.

### Review findings and follow-up

| ID | Artefact / finding | Required correction or verification | Status | Follow-up evidence |
|---|---|---|---|---|
| IR-S4-01 | Sale and SaleLine responsibilities | Ensure that Sale owns its lines, SaleLine calculates its net amount, and SaleService coordinates sale creation. | Changed | The sequence diagram and CRC cards have been updated. The `addLine(line)` operation is correctly assigned to Sale. |
| IR-S4-02 | Class relationships and object validity | Ensure that a completed Sale contains at least one SaleLine and that every recorded line retains maker attribution. | Changed | Multiplicities and relationships have been corrected in the integrated class diagram. Existing Gherkin scenarios cover empty requests and missing maker attribution. |
| IR-S4-03 | Stock availability and sale consistency | Use the shared StockAvailabilityPort and ensure that an unsuccessful sale does not result in partial stock updates. | Changed | The integrated class diagram, operation contract and GRASP decisions describe the all-or-nothing consistency requirement. The concrete transaction mechanism remains outside the CA2 scope. |
| IR-S4-04 | Idempotency and offline reconciliation | Align the sale-recording operation, repository signatures and recovery behaviour with the shared SaleRecordingPort. Preserve the original saleRef and offline source reference. | Changes requested | Document the all-or-nothing consistency requirement for sale recording and stock updates. |
| IR-S4-05 | Processor identity and authorisation | Ensure that sales are recorded by authorised users and retain the responsible processor's identity. | Changes requested | Authorisation and processedBy are already included in the design. A consistent shared approach to authenticated user identity remains to be agreed. |

## 4. Shared follow-up and review coverage

Slice owners were asked to update existing artefacts, commit and push their corrections, and complete their individual entries in `ca2-analysis/ai/interaction-log.md` with actual tool use, prompts, affected artefacts and verification. Separate contracts are not required for internal methods.

| Design thread | Review type | Follow-up outcome |
|---|---|---|
| UC-02 — Slice 1 | Original group review and document verification | Requested changes substantially present; remaining alignment findings open. |
| UC-04 — Slice 2 | Outside this review | The current archive contains Slice 2 artefacts, but they have not been reviewed in this record. The integrated class diagram still covers Slices 1, 3 and 4. |
| UC-10 — Slice 3 | Original group review and document verification | Six review findings have been addressed; one remaining issue concerns the shared authenticated user identity.|
| UC-01 — Slice 4 | Self-review + Bogdan Byrdin | Integrated model changes verified; provider and contract alignment remain open. |
