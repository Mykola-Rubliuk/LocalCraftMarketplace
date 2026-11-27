# CA2 Group Design Dossier
## Local Craft Marketplace — Kerry Makers Cooperative

| Submission information | Details |
|---|---|
| Module | OOAD |
| Assessment | CA2 — Collaborative Object-Oriented Design |
| Group members | Mykola Rubliuk, Bogdan Byrdin, Marian Andrei Rogojina, Maryna Tarasova |
| Repository | [LocalCraftMarketplace](https://github.com/Mykola-Rubliuk/LocalCraftMarketplace) |
| Submission tag | `ca2-submission` |

---

## 1. Product Goal

The group retained the [Product Goal](../docs/product-goal.md) established for the marketplace: enable authorised Kerry Makers Cooperative staff to maintain accurate records of products, stock availability, reservations, multi-maker order fulfilment and sales, including controlled reconciliation of offline market transactions. The intended outcomes are fewer conflicting commitments, better visibility of order progress, reliable evidence for makers and restricted access to confidential information.

CA1 identified fragmented spreadsheets, handwritten records and messages as obstacles to reliable operational records. CA2 addresses this problem through the object-oriented design of selected behaviours rather than changing the underlying business goal. The system supports staff in recording decisions and transactions; physical production, collection and payment remain outside its responsibilities.

## 2. Scenario Selection and Agreed Baseline

The group considered Local Craft Marketplace and Renewable Energy Maintenance Service. Both scenarios offered opportunities to model entities, state changes and exceptional behaviour. The maintenance scenario offered a focused context for equipment-related workflows, whereas the marketplace provided several distinct but connected business processes. Selecting a limited set of these processes made the wider marketplace domain manageable within CA2.

The marketplace was selected because its workflows have meaningful dependencies. Reservations affect stock availability; sales change that availability while preserving maker attribution; orders contain lines that progress independently; and offline transactions require reconciliation against existing commitments. These dependencies provide opportunities to demonstrate responsibility allocation, shared interfaces and consistency between related operations. They also allow individual design work to contribute to a common architecture instead of producing four unrelated subsystems.

The [scenario-selection record](../docs/scenario-selection.md) documents the comparison and records group approval of the scenario and four-slice scope. The [agreed baseline](../docs/agreed-baseline.md) identifies the retained CA1 actors, requirements, business rules, assumptions, use cases and scenarios. UC-10 is included in the documented group scope. The scenario-selection record provides the rationale for the scope, while the baseline restatement identifies the requirements carried forward into the design. The original requirement identifiers provide a common reference for the individual slices.

The design retains the CA1 use-case identifiers and uses `saleRef` consistently for successful sale recording. Common identifiers support traceability across individual slices and their shared interfaces. The [decision log](../decisions/decision-log.md) records architectural choices, alternatives and their rationale. The design distinguishes the scope of each use case from the technical details needed to support it. For example, the identity of the person recording a transaction is part of the business evidence, whereas the mechanism for obtaining that identity belongs to the design. Reservation duration, stock quantity semantics and the concrete persistence mechanism are documented as open questions and implementation considerations. This allows the selected behaviours to be described without fixing every detail of the underlying infrastructure.

## 3. Selected CA2 Design Scope

Four use cases were selected for their business value, design challenges and the opportunity for each member to own a substantial slice. Their common goal is accurate records of commitments, stock and transactions. The shared dependencies make them parts of one system rather than four separate designs.

| Slice / canonical use case | Stakeholder value | Requirements / rules | Dependencies and selection reason |
|---|---|---|---|
| 1 — UC-02 Manage Reservation | Avoid incompatible promises, preserve reservation terms | FR-04, FR-05; A-01/A-02 | StockAvailabilityPort, Clock, ReservationPolicy; time and availability invariants |
| 2 — UC-04 Manage Customer Order (fulfil order lines) | Make partial progress and customer decisions visible | FR-06 context, FR-07; BR-02, BR-03; A-04 | Existing orders, line states, accountable changes; aggregate behaviour |
| 3 — UC-10 Reconcile Offline Transactions | Prevent loss and duplicate recording of offline sales | FR-13, NFR-05; A-08/A-10, BR-01, BR-05 | StockAvailabilityPort, SaleRecordingPort, Clock; cross-slice failure and retry behaviour |
| 4 — UC-01 Process Customer Sale | Record valid sales with maker-attributable evidence | FR-01, FR-04, FR-10; BR-01 | StockAvailabilityPort, ProductCatalogue, Clock; atomic sale recording |

The brief and the rubric describe scope differently — one to three significant use cases versus three to five substantial ones. Four falls within the rubric range and provides a substantial design thread for each member.
UC-04 is limited to fulfilment of existing orders rather than order creation: FR-06 provides structural context and FR-07 is the direct behavioural target. Public e-commerce, payments, full accounting, delivery integration and automatic offline synchronisation remain outside scope. The integrated class diagram represents all four slices. Each slice has a use case, Gherkin, SSD, operation contracts, CRC, GRASP and object-interaction artefacts. Together, these artefacts provide complementary views of the expected behaviour and object responsibilities.

## 4. Behavioural Design

### 4.1 Slice 1 — UC-02 Manage Reservation

A Shop Volunteer records a customer's request to reserve an item. `recordReservation(itemCode, customerRef, conditions, userId)` checks the required details, existing reservations and stock availability. Clock supplies the current time, and ReservationPolicy calculates expiry. On success, the system creates an Active Reservation containing its reference, customer, conditions, expiry and the responsible volunteer's identifier. The item becomes Reserved before confirmation is returned.

This supports FR-04 and FR-05: the reservation record and stock status must agree. A failed persistence or stock update must not leave partial changes. `ConflictingReservation` indicates an existing active reservation, while `ItemUnavailable` covers other situations where the item cannot be reserved. Distinguishing them gives the volunteer a clearer explanation of the refusal.

`evaluateExpiry(asOf)` finds active reservations whose expiry has been reached. The reservation becomes Expired, and stock is released only if no other commitment applies. Repeating the operation must not release stock again. Gherkin covers repeated expiry, persistence failure and expiry with another commitment. The three-working-day examples illustrate the expiry policy without imposing a fixed duration on every reservation.

The scenario “Evaluate an expired reservation more than once” is particularly useful because it checks the effect of repeating an operation rather than just the first successful result. Both operations have SSD, contract and internal interaction coverage. The interaction diagrams and contracts describe the reservation and expiry workflows from different perspectives. The remaining details concerning `userId`, rollback and technical failure results are captured as alignment findings in the integration review.

**Evidence:** [Use case](../slices/slice-1/use-case.md), [Gherkin](../slices/slice-1/features/reservation.feature), [SSD](../slices/slice-1/ssd/ssd.puml), [contracts](../slices/slice-1/contracts/contract.md), [reserve interaction](../slices/slice-1/sequence/Reserve-Item.puml), [expiry interaction](../slices/slice-1/sequence/Expiry-evaluation.puml).

### 4.2 Slice 2 — UC-04 Manage Customer Order (Fulfil Order Lines)

A Shop Volunteer updates an existing order when a maker finishes an item, a customer collects it, or a customer agrees to a substitution or cancellation. The Customer and Maker participate outside the system. FR-07 and BR-03 require independent line progress, while BR-02 allows different makers to contribute to the same order.

The SSD and contracts define `viewOrder`, `markReady`, `recordCollection` and `recordCustomerDecision`. Viewing does not change state. A successful modification affects only the selected line, records who changed it and when, and recalculates the order status.

A line moves from BeingMade to Ready and then Collected. Open lines may also become Cancelled or Substituted. These two states and Collected are closed states; the order becomes Completed only when every line is closed. Completion therefore does not necessarily mean every item was collected. The state diagram and Gherkin describe valid transitions and refusals. In particular, “Progress update leaves other lines unchanged” tests the independence of order lines, while “Closing the last open line completes the order” checks the aggregate completion rule. Invalid changes leave the order unchanged, and customer decisions require a predefined reason, including `NotGiven` where appropriate.

The order and changed line must be saved consistently. Clock supplies the timestamp, while CurrentUser is represented in the Slice 2 object design as the source of volunteer identity (D-CA2-18). Keeping the identity lookup separate from the line-change operations avoids passing a volunteer identifier as an additional input to each operation. Customer approval is recorded rather than independently verified; manager reversion and editable reasons remain outside the selected scope.

**Evidence:** [Use case](../slices/slice-2/use-case.md), [Gherkin](../slices/slice-2/features/order-fulfilment.feature), [SSD](../slices/slice-2/ssd/ssd.puml), [contracts](../slices/slice-2/contracts/operation-contracts.md), [CRC](../slices/slice-2/crc/crc.md), [GRASP](../slices/slice-2/grasp/grasp.md), [interactions](../slices/slice-2/sequence/sequence.puml), [state diagram](../slices/slice-2/state/order-line-state.puml).

### 4.3 Slice 3 — UC-10 Reconcile Offline Transactions

A Market Coordinator enters handwritten offline sales after connectivity returns. `enterOfflineTransaction` validates the reference, transaction date, items and prices. Each entry has a unique `entryId`, while `offlineRef` preserves the original reference. `submissionId` distinguishes a retry from a separate form with the same reference.

A new entry normally starts AwaitingReconciliation; duplicate references are referred to the Manager. Reconciliation and resolution identify entries by `entryId`, avoiding ambiguity. ConflictChecker checks duplicates and stock availability. Sold, Reserved or Unknown stock prevents a new sale. Slice 3 delegates sale recording to SaleRecordingPort and marks an entry Reconciled only after `Recorded(saleRef)`.

The original SaleRequest is saved and reused during retries, using `entryId` as its idempotency key and `offlineRef` as its source reference. `findRecordedResult(request)` checks for an earlier successful sale before stock conflicts are evaluated. If a sale already exists, its reference is recovered without recording another sale. An absent result permits normal checks; a technical lookup failure leaves the entry retryable. This prevents a lost success response from being mistaken for a new stock conflict.

The Manager resolves a referral by recording a decision, note, author and timestamp. Resolution does not automatically create a sale. The duplicate, resolution and retry scenarios support FR-13 and NFR-05. Referring a duplicate rather than silently discarding it preserves evidence for management review, even when the submitted transaction cannot be accepted as a sale. Consistent identification of authorised callers remains an open integration issue.

**Evidence:** [Use case](../slices/slice-3/use-case.md), [Gherkin](../slices/slice-3/features/offline-reconciliation.feature), [SSD](../slices/slice-3/ssd/ssd.puml), [contracts](../slices/slice-3/contracts/operation-contracts.md), [object interaction](../slices/slice-3/sequence/sequence.puml).

### 4.4 Slice 4 — UC-01 Process Customer Sale

A Shop Volunteer or Market Coordinator records a purchase through `recordSale(request: SaleRequest)`. The request contains the processor, channel, idempotency key, optional customer and source references, and the sale lines. Each line identifies the item, quantity, actual price and optional discount.

SaleService validates the request, checks idempotency, obtains product and maker details from ProductCatalogue and checks stock. When all lines are valid, it creates the Sale and SaleLine objects and coordinates the stock update. SaleRepository retains the sale and its idempotency evidence. Success returns a unique `saleRef` and confirms the completed sale and Sold stock.

Retaining maker attribution and actual transaction amounts supports BR-01 and FR-10. Updating availability supports FR-04. For offline sales, the original sale date remains distinct from the recording time. Gherkin covers sales involving multiple makers and rejection of the whole sale when one item is unavailable. Empty requests, invalid amounts or quantities, missing maker details and unauthorised processing are also refused. Reserved items are excluded from ordinary sales under the current stock rules.

OC-4.1 specifies that a matching repeated request returns the original result, while a changed request with the same key is rejected. IdempotencyRecord stores the key, request fingerprint and original sale reference for this comparison. The check must take place before stock validation on a retry, because the first successful sale may already have changed the stock status. OC-4.2 defines read-only `findRecordedResult(request)` for offline reconciliation. Both operations distinguish technical failures from business refusals. The sale and stock changes must be consistent; concrete transaction handling and cross-slice identity consistency are further design considerations.

**Evidence:** [Use case](../slices/slice-4/use-case.md), [Gherkin](../slices/slice-4/features/customer-sale.feature), [SSD](../slices/slice-4/ssd/ssd.puml), [contract](../slices/slice-4/contracts/operation-contracts.md), [object interaction](../slices/slice-4/sequence/sequence.puml).

## 5. Responsibility and Object Design

The [integrated class diagram](../design/integrated-design-class-diagram.puml) and its [description](../design/integrated-design-class-diagram.md) represent the four-slice object model and the shared capabilities through which the slices collaborate. The diagram is a design reference rather than a specification of concrete database or authentication infrastructure.

### 5.1 Principal CRC responsibilities

The following table summarises the principal responsibilities documented in the individual CRC cards.

| Class / capability | Principal responsibility | Collaborators |
|---|---|---|
| ReservationService | Coordinate reservation and expiry operations | Reservation, ReservationPolicy, ReservationRepository, StockAvailabilityPort, Clock |
| Reservation | Retain customer, item, conditions, status and expiry | ReservationService, ReservationRepository |
| ReservationPolicy | Calculate agreed expiry from policy | ReservationService; calendar policy |
| OrderFulfilmentService | Coordinate order lookup and line changes | CustomerOrder, CustomerOrderRepository, Clock, CurrentUser (Slice 2) |
| CustomerOrder / OrderLine | Retain lines, line status and derived order progress; record decisions | Each other; fulfilment controller |
| OfflineReconciliationService | Coordinate entry, conflict checks, reconciliation and manager resolution | OfflineTransaction, ConflictChecker, repository, SaleRecordingPort, Clock |
| OfflineTransaction | Retain form details, lifecycle, referral and resolution evidence | OfflineLine, controller, repository |
| ConflictChecker | Detect duplicate references and unavailable items | OfflineTransactionRepository, StockAvailabilityPort |
| SaleService | Validate, coordinate and record a sale through the shared port | Sale, SaleLine, ProductCatalogue, SaleRepository, stock port, Clock |
| Sale / SaleLine | Own transaction and line evidence; calculate monetary totals | Each other, controller, catalogue entities |

### 5.2 Significant GRASP decisions

**Controller — application services (D-CA2-01).** ReservationService, OrderFulfilmentService, OfflineReconciliationService and SaleService each receive the system events for their own use case. Giving entities responsibility for repositories and stock access would couple them to infrastructure. A single generic controller would combine unrelated workflows. Separate use-case controllers keep coordination clear and entities focused on their state.

**Information Expert — Reservation and ReservationPolicy (D-CA2-05).** Reservation knows its own expiry and status; ReservationPolicy knows how to calculate a new one under the agreed rules. Calendar arithmetic inside ReservationService would mix policy with orchestration, and a policy change would ripple into an otherwise stable use case. The shared Clock supplies `now()` without performing policy calculations.

**Information Expert — OrderLine and CustomerOrder (D-CA2-06).** OrderLine owns its status and transition rules, while CustomerOrder derives completion from its lines. A single order-level status would hide partial readiness. The Slice 2 CRC and GRASP records assign transition rules to OrderLine and aggregate completion to CustomerOrder, keeping these business rules separate from service orchestration.

**Creator and Information Expert — OfflineReconciliationService and OfflineTransaction.** The controller holds the initial form data, so it creates the OfflineTransaction and OfflineLine objects; the entity then owns its own lifecycle through `markReconciled`, `refer` and `resolve`. A repository that also decided state would mix storage with business logic.

**Pure Fabrication and High Cohesion — ConflictChecker.** Duplicate detection needs stored references, while stock conflict detection needs availability data. Neither responsibility belongs to an individual offline line. A dedicated checker groups the rules and keeps them independently testable.

**Information Expert — Sale and SaleLine.** A line calculates its own net amount from its own quantity, price and discount; Sale derives the total from its lines. Placing these calculations in SaleService would separate behaviour from the data it uses and increase controller complexity. ProductCatalogue keeps product/maker lookup separate from the sale workflow.

**Pure Fabrication — repositories.** ReservationRepository, CustomerOrderRepository, OfflineTransactionRepository and SaleRepository concentrate persistence so domain objects don't need to understand storage. The trade-off: this doesn't by itself guarantee a transaction boundary where repositories and stock storage must change together.

**Indirection and Protected Variations — shared ports (D-CA2-03/04/08).** StockAvailabilityPort gives one shared stock vocabulary; SaleRecordingPort gives one sale-recording boundary. Letting Slice 3 create sales or touch stock directly would duplicate validation and risk inconsistent outcomes. Shared interfaces let fakes be tested against one common contract; Clock applies the same idea to time. For example, a test clock can make expiry scenarios repeatable without depending on the real date. A stock fake can supply known availability states to exercise refusal paths independently of a database.

### 5.3 Integrated collaboration

Slice 1 reserves or releases stock; Slice 3 checks stock and hands off sale recording; Slice 4 creates sales and drives the Sold transition. Slice 2 tracks order-line progress and does not create a sale when collection is recorded. Its service, aggregate, repository and identity collaborator are represented in the integrated model. Clock is shared by all four slices; sale recording and stock transitions remain with their designated providers.

**CRC and GRASP evidence:** [Slice 1](../slices/slice-1/crc/crc.md)/[GRASP](../slices/slice-1/grasp/grasp.md); [Slice 2](../slices/slice-2/crc/crc.md)/[GRASP](../slices/slice-2/grasp/grasp.md); [Slice 3](../slices/slice-3/crc/crc.md)/[GRASP](../slices/slice-3/grasp/grasp.md); [Slice 4](../slices/slice-4/crc/crc.md)/[GRASP](../slices/slice-4/grasp/grasp.md).

## 6. Design Structure and Shared Interfaces

The [package/layer view](../design/package-layer-view.puml) groups the design into application services, domain objects, shared contracts and infrastructure boundaries. It is a structural view rather than a deployment diagram. The integrated class model provides the more detailed reference for the four slices, including order fulfilment.

Application services coordinate domain objects and repositories; shared abstractions isolate cross-slice dependencies. Concrete database, stock and time providers stay unspecified.

| Shared interface | Operations / result | Responsibility |
|---|---|---|
| StockAvailabilityPort | `getStatus`, `reserveIfAvailable`, `releaseIfReserved`, `sellAllIfAvailable` | Consistent stock status and controlled transitions |
| SaleRecordingPort | `recordSale(SaleRequest)` and `findRecordedResult(SaleRequest)` → recorded / rejected; recovery may return null | One authoritative sale boundary; provided by SaleService |
| Clock | `now(): DateTime` | Supply time without embedding the system clock in business rules |
| CurrentUser (Slice 2) | `getUserId()` | Provide the signed-in volunteer identity without coupling fulfilment to authentication infrastructure |

Available, Reserved, Sold and Unknown are the shared stock statuses. Unknown is not Available. Stock-service failures are technical errors. Slice 3 referral reasons describe business conflicts requiring management review.

The error catalogue separates business refusals from technical failures. A failure cannot be treated as confirmation. The stock port must recheck availability when changing it because earlier information may be outdated.

The [shared interface catalogue](../design/shared-interface-catalogue.md) and [error catalogue](../design/operation-error-catalogue.md) hold the full definitions; the [shared contract test plan](../design/shared-contract-test-plan.md) specifies tests for status transitions, idempotency, maker attribution and cross-slice interaction — a specification, not executed results. CurrentUser describes the identity boundary within Slice 2. Cross-slice identity consistency remains an open design question.

## 7. Traceability

The [CA2 traceability matrix](../backlog/traceability.csv) connects the selected use cases to backlog items, CA1 requirements, Gherkin, SSDs, operation contracts, CRC/GRASP, interactions and design classes. The CA1 matrix remains the requirements reference. The following table summarises the actual artefact coverage of the current design; the separate CSV retains some earlier coverage labels, so the linked artefacts and the table below provide the current reference for design coverage.

| Use case | CA2 work | CA1 evidence | Current design coverage |
|---|---|---|---|
| UC-02 | PB-04 / AD-01 / US-01 | TR-02; SC-01–03 | Use case, Gherkin, SSD, contracts, CRC/GRASP, two interactions and integrated classes |
| UC-04 | PB-05 / AD-02 / US-02 | TR-04; SC-04 | Use case, Gherkin, SSD, four contracts, CRC/GRASP, interactions, state diagram and integrated classes |
| UC-10 | PB-06 / AD-03 / US-CA2-01 | TR-10; US-09; SC-11–15 | Principal artefacts, entry-based operations and recovery design |
| UC-01 | PB-03 / AD-04 / US-05 | TR-07; SC-07 | Principal artefacts, recording and recovery contracts, integrated classes |

Traceability establishes why an operation exists and which design evidence describes its effects. It is not proof of implementation or successful execution. FR-06 remains context for Slice 2, not a claim that order creation is designed. US-CA2-01 links offline reconciliation to its CA1 predecessor US-09. Maintaining the CSV alongside the design artefacts and recording review outcomes supports traceability and quality control. For example, a change to an operation signature should be reflected in the SSD, its contract, the internal sequence and the integrated class model. A linked Gherkin scenario then provides a reference for checking the intended outcome.

## 8. Design Evaluation

The main strength is the separation of coordination from domain state. Controllers manage each workflow, while entities retain business responsibilities rather than acting only as data holders. The order model also represents independent line progress without requiring a separate service for every calculation. These choices support high cohesion.

Shared stock and sale contracts reduce coupling. Slice 3 reuses the ordinary sale capability rather than duplicating maker attribution and stock updates. The trade-off is that all consumers must interpret the interfaces consistently. A renamed method or different interpretation of Unknown stock could break integration. Shared contract tests can help detect these problems, including when a fake provider is used.

Object validity depends on consistent state changes and persistence. A reservation must agree with stock status. A valid Sale needs maker-attributed lines, and failure of one line must not leave the others sold. The class diagram describes these responsibilities, but independent calls to stock and sale storage aren't enough on their own to guarantee atomicity — that needs a shared transaction or recovery protocol at implementation time. This is a significant implementation risk that the design explicitly acknowledges.

Idempotency requires enough stored information to distinguish an identical retry from a changed request. Reconciliation must recover an earlier sale rather than mistake Sold stock for a new conflict. The updated SaleRequest, IdempotencyRecord and recovery operation address these concerns at design level, but their guarantees still depend on correct implementation. Similarly, the recorded user identifiers support accountability but lack a common trusted identity source. A shared user context could reduce this variation by separating authentication infrastructure from the business operations.

Several trade-offs are deliberate. Reservation duration is configurable, and Reserved stock is excluded from ordinary sales under the current design. Stock quantity also needs clarification because a single Sold status may not represent a partially sold batch. Order fulfilment retains the last change rather than a full audit history. Customer approval cannot be independently verified by the system. These choices reduce design complexity but leave operational risks.

The design provides a coherent basis for implementation. The main risks concern consistency between operation signatures, the treatment of exceptional scenarios and the interpretation of shared business rules. Addressing these through existing contracts and review records is preferable to adding more classes. The [open questions](../decisions/open-questions.md) document policy details and integration risks.

## 9. Process, Review and Individual Evidence

The [Product Backlog](../backlog/product-backlog.md) defines individual slice work and shared integration tasks. The [iteration plan](../project-management/iteration-plan.md) sequences baseline agreement, shared contracts, individual design, integration and final evidence. The [Definition of Done](../project-management/definition-of-done.md) requires editable sources, terminology alignment, traceability, peer review and AI disclosure. Backlog entries identify the planned work, while the linked design artefacts and review records provide evidence of its current state.

The [decision log](../decisions/decision-log.md) retains alternatives and their rationale. The [integration review](../reviews/integration-review.md) records specific findings and follow-up for Slices 1, 3 and 4, including responsibility allocation, shared operation signatures and recovery behaviour. The review records document-level findings, corrections and open items rather than executed test results. Its recorded coverage is Slices 1, 3 and 4, including technical self-review for Slice 4. The record does not cover Slice 2. This distinction keeps the design artefacts and the evidence of review separate.

The [retrospective](../docs/reflection/retrospective.md) identifies the value of dividing the work into slices and the difficulty of integrating work delivered at different stages. Earlier agreement on shared interfaces, intermediate deadlines and assigned reviewers are the proposed improvements.

## 10. Conclusion and Limitations

The CA2 design translates the marketplace requirements into four behavioural slices connected by shared interfaces. Reservation and sale coordinate stock availability, offline reconciliation uses the same sale-recording capability, and order fulfilment tracks independent line progress. The integrated class diagram represents all four areas, supported by contracts and responsibility-based object design.

The main limitations concern cross-slice identity consistency, reservation and stock policy details, implementation-level transaction guarantees and documentation alignment. These are recorded as open questions, design constraints and review findings. The work establishes design intent rather than a functioning application. A subsequent implementation could use the operation contracts and scenario specifications to validate the expected behaviours, particularly stock consistency, line transitions and safe transaction retries. Concrete infrastructure and deployment decisions are outside the CA2 scope.
