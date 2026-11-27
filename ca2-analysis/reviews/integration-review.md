# CA2 Integration Review

**Project:** Local Craft Marketplace — Kerry Makers Cooperative  
**Reviewer (Slices 1 and 3):** Mykola Rubliuk  
**Slice 4:** Self-review; Bohdan Byrdin is listed in the review record. 
**Scope:** Slices 1, 3 and 4.

This review records design corrections visible in the reviewed artefacts. Changed does not imply executed tests or formal approval.

## Slice 1 — UC-02 Manage Reservation

### Changed

- **IR-S1-01–03 — Sequence:** Replaced `markReserved` with `reserveIfAvailable`, completed `validateRequest(itemCode, customerRef, conditions)`, moved expiry calculations to `ReservationPolicy.calculateExpiry(currentDateTime)` using `Clock.now()`, and placed confirmation after successful stock reservation and persistence.
- **IR-S1-04–05 — CRC and GRASP:** Aligned responsibilities for validation, repository retrieval (`findActiveByItemCode`, `findAllActive`), expiry policy, stock transitions (`reserveIfAvailable`, `releaseIfReserved`) and time access.
- **IR-S1-06 — Contracts and Gherkin:** Distinguished `ConflictingReservation` from `ItemUnavailable`; added `StockUpdateFailed`, `StockServiceUnavailable`, `PersistenceFailed` and scenarios covering failed persistence and expiry with another commitment.
- **IR-S1-07 — Documentation:** Added the SSD with both operations and placed README and use-case files in the slice root.

### Changes requested

- **IR-S1-08:** Align `rollbackReservation(reservation)` with the repository model or document rollback as a transaction constraint.
- **IR-S1-09:** Align technical-failure results with `ReservationTechnicalFailure`, including expiry failure signalling, and clarify refusal precedence.

**Evidence:** Slice 1 sequence diagrams, SSD, CRC, GRASP, contracts and Gherkin. Seven findings addressed; two remain open.

## Slice 3 — UC-10 Reconcile Offline Transactions

### Changed

- **IR-S3-01 — Operations:** Aligned SSD, sequence and contracts with `entryId`, `saleRef`, `recordedBy`, `findByEntryId`, `getStatus`, `requireCoordinatorRole` and `recordSale(request: SaleRequest)`.
- **IR-S3-02 — SaleRequest:** Added the shared fields: `idempotencyKey = entryId`, authorised coordinator as `processedBy`, `OfflineMarket` channel, null `customerRef`, original `saleDate`, `sourceRef = offlineRef` and transaction lines containing `itemCode`, `quantity`, `soldPrice` and optional discount.
- **IR-S3-03–04 — Recovery:** Persisted the original request, placed `findRecordedResult` before conflict checks, recovered the original `saleRef`, reused the request on retries and documented key conflicts and technical failures. Technical failures retain AwaitingReconciliation; a conflicting or failed lookup must not be interpreted as an absent result.
- **IR-S3-05–06 — CRC and GRASP:** Aligned service coordination, repository lookup (`findByEntryId`, `findBySubmissionId`, `existsOtherWithRef`), `ConflictChecker.check`, sale recovery and the OfflineLine data. Documented `recordedBy`, `referralDetail`, `saleRef`, `saleRequest`, `decision`, `resolutionNote`, `resolvedBy` and `resolvedAt`.

### Changes requested

- **IR-S3-07:** Clarify the trusted source of `recordedBy`, `resolvedBy` and `processedBy` without modifying the saved request during retries.

**Evidence:** Slice 3 SSD, sequence, contracts, CRC, GRASP and Gherkin. Six findings addressed; one remains open.

## Slice 4 — UC-01 Process Customer Sale

### Changed

- **IR-S4-01–02 — Responsibilities and relationships:** Corrected `Sale.addLine(line)`, clarified Sale/SaleLine responsibilities and multiplicities, and retained mandatory maker attribution.
- **IR-S4-03 — Stock consistency:** Documented all-or-nothing sale and stock updates through the shared stock port. The transaction mechanism is an implementation concern.

### Changes requested

- **IR-S4-04:** Align the individual contracts, sequence and repository operations with `IdempotencyRecord`, `findRecordedResult` and retained `sourceRef` in the integrated model.
- **IR-S4-05:** Agree on a shared approach to authenticated processor identity; retain `processedBy` for accountability.

**Evidence:** Slice 4 sequence, CRC, GRASP, contracts, Gherkin and integrated class diagram. Three findings addressed; two remain open.