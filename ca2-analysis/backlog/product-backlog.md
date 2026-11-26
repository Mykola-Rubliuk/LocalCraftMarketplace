# CA2 Product Backlog — Local Craft Marketplace

**Project:** Local Craft Marketplace — Kerry Makers Cooperative  
**Product Goal:** Enable authorised Kerry Makers Cooperative staff to maintain reliable records of item availability, reservations, multi-maker order fulfilment and sales, including maker attribution and later reconciliation of market transactions captured offline.
---
| ID | Type | Item / outcome | Priority | Owner | Acceptance / completion evidence | Status |
|---|---|---|---|---|---|---|
| PB-01 | Baseline | Confirm scenario, CA1 links, UC-10 extension and lecturer scope clarification | Must | Group | Approved baseline and change log | Ready |
| PB-02 | Enabler | Agree shared StockAvailabilityPort, SaleRecordingPort and Clock contracts | Must |  Cross-slice reviewers | Interface catalogue and contract tests agreed | Ready |
| PB-03 | Design | UC-01 Process a customer sale (Slice 4) | Must | Slice 4 owner | Use case, Gherkin, SSD, contracts, CRC/GRASP, sequence reviewed | In Progress |
| PB-04 | Design | UC-02 Reserve an item (Slice 1) | Must | Slice 1 owner  | Same artefact set; expiry policy assumption explicit | In Progress |
| PB-05 | Design | UC-04 Fulfil order lines (Slice 2) | Must | Slice 2 owner | Same artefact set; approval evidence handled | In Progress |
| PB-06 | Design / risk | UC-10 Reconcile offline transactions (Slice 3) | Must, pending scope | Slice 3 owner | Clean, duplicate, conflict and manager-resolution paths; design in `slices/slice-3/offline-reconciliation-design.md` | In Progress (scope pending PB-01) |
| PB-07 | Integration | Build integrated design class model and check message-operation mapping | Must | Group integration owner | One coherent class model matching all sequences | Backlog |
| PB-08 | Enabler | Produce package/layer view and interface/error catalogue | Should | Group  | Dependencies point inward to domain/application abstractions | Backlog |
| PB-09 | Quality | Complete cross-slice traceability | Must | Group | Every selected UC has a complete chain | Backlog |
| PB-10 | Review | Peer review each selected slice | Must | Reviewer per slice | Review comments resolved or disposition recorded | Backlog |
| PB-11 | Evaluation | Evaluate cohesion, coupling, controller choice, assumptions and alternatives | Must | Group  | Design evaluation in dossier | Backlog |
| PB-12 | Evidence | Complete AI log, group declaration and individual contribution statements | Must | Every member  | Truthful declarations and evidence links | Backlog |
| PB-13 | Submission | Render diagrams, verify links, tag reviewed submission | Must | Group  | `ca2-submission` tag after final approval | Backlog |



## 1. Purpose and Backlog Conventions

This Product Backlog contains the work required to design, review and document the CA2 Local Craft Marketplace system.

It builds on the requirements, business rules, use cases, user stories, Gherkin scenarios and domain model produced during CA1.

The backlog contains five item types:

1. User Story
2. Analysis / Design Task
3. Risk or Spike
4. Defect or Inconsistency
5. Design Enabler

Each item has a stable identifier. Items should be ordered according to business value, risk, dependencies and learning needs rather than individual member preference.

The backlog is the authoritative record of work items. GitHub Projects is used to track their status, ownership, deadlines and review progress. The board should link to repository evidence rather than duplicate complete diagrams, use cases or contracts.

### 1.1 Workflow statuses

| Status | Meaning |
|---|---|
| Backlog | Identified but not yet selected for active work |
| Ready | Clarified and ready to be started |
| In Progress | Currently being worked on |
| Peer Review | Awaiting review by another team member |
| Blocked | Cannot progress until a dependency or question is resolved |
| Done | Completed, reviewed and supported by repository evidence |

**Important:** All items initially marked `Backlog` are proposed work items, not evidence of completed work.

### 1.2 Priority levels

| Priority | Meaning |
|---|---|
| High | Essential to the selected design scope or a critical dependency |
| Medium | Important for consistency, quality or risk reduction |
| Low | Useful improvement that does not block the main design |

Priorities are provisional and should be confirmed by the group.

### 1.3 Ownership convention

For items selected for an iteration:

- **Owner:** Responsible for completing the item.
- **TBC:** Must be assigned by the group before the item enters an active iteration.

The four Slice owners are assigned according to the group's agreed division of work.

---

# 2. User Stories

User stories express stakeholder value. They do not replace formal requirements, detailed use cases, operation contracts or Gherkin scenarios.

CA1 story identifiers are retained where known. A new CA2 story is explicitly identified as a proposal where the selected CA2 scope extends the original CA1 analysis.

## US-01 — Reserve an Item

**Type:** User Story  
**Source:** CA1  
**Value statement:**

As a Shop Volunteer, I want to reserve an available item for a customer so that the cooperative does not make conflicting commitments.

**Business value:** Prevents the same physical item from being committed to multiple customers.

**Priority:** High  
**Related requirements:** FR-04, FR-05  
**Related use case:** UC-02 Manage Reservation  
**Related business rule:** BR-04  
**Related Gherkin:** SC-01, SC-02, SC-03  
**Related Slice:** Slice 1 — Reservation

**Acceptance criteria:**

1. Given an item is available, when an authorised volunteer records a reservation with the agreed conditions, then the reservation is recorded and the item is no longer shown as freely available.
2. Given an item is already sold or has an active reservation, when a volunteer attempts to reserve it, then the system must not confirm a second active reservation.
3. Given a reservation has an agreed expiry date, when that date is reached, then the reservation must no longer be treated as an active hold, subject to any other restriction on the item.

**Open question:** Q-01 — Reservation expiry policy. No universal reservation duration is treated as confirmed.

**Links:** CA1 FR-04/FR-05, UC-02, SC-01–SC-03, Slice 1 design artefacts.

**Status:** Backlog  
**Owner:** Slice 1 owner  

---

## US-02 — Track Partial Order Fulfilment

**Type:** User Story  
**Source:** CA1  
**Value statement:**

As a customer, I want each line of my order to have its own fulfilment status so that I can tell which items are ready and which are still being made or sourced.

**Business value:** Improves visibility of multi-maker orders and prevents the status of one item from incorrectly representing the entire order.

**Priority:** High  
**Related requirements:** FR-06, FR-07  
**Related use case:** UC-04 Manage Customer Order  
**Related business rule:** BR-02, BR-03  
**Related Gherkin:** SC-04  
**Related Slice:** Slice 2 — Customer Order

**Acceptance criteria:**

1. Given an order contains multiple lines, when one line becomes ready, then its status can be updated without changing the status of other lines.
2. Given an order contains items from multiple makers, then the system must retain the individual order-line information required to track their fulfilment independently.

**Open question:** Q-03 — Approval evidence for substitutions and cancellations.

**Links:** CA1 FR-06/FR-07, UC-04, SC-04, Slice 2 design artefacts.

**Status:** Backlog  
**Owner:** Slice 2 owner  

---

## US-03 — Control Commission Changes

**Type:** User Story  
**Source:** CA1  
**Value statement:**

As a Manager, I want proposed changes to commissioned work recorded separately from approved terms so that the cooperative can identify what has and has not been agreed.

**Business value:** Reduces disputes about changes to specifications, prices and target dates.

**Priority:** Medium  
**Related requirement:** FR-08  
**Related use case:** UC-05 Record Commission Change  
**Related Gherkin:** SC-05

**Acceptance criteria:**

1. Given a commission has approved terms, when a change to materials, price or target date is proposed, then the proposal is recorded without silently replacing the approved terms.
2. The approved terms remain identifiable while the proposed change is awaiting the required approval.

**Open question:** Q-04 — Which commission changes require customer and maker approval?

**Scope note:** UC-05 is part of the CA1 analysis but is not one of the four currently selected CA2 slices.

**Links:** CA1 FR-08, UC-05, SC-05, Q-04.

**Status:** Backlog — not selected as a principal CA2 slice  
**Owner:** TBC  

---

## US-05 — Record a Customer Sale

**Type:** User Story  
**Source:** CA2 slice planning, based on CA1 requirements  
**Value statement:**

As an authorised Shop Volunteer, I want to record a customer sale with its item details, prices and maker attribution so that sales are accurately recorded and can support later maker transaction reconciliation.

**Business value:** Provides reliable sales evidence and reduces errors in maker attribution and transaction records.

**Priority:** High  
**Related requirements:** FR-01, FR-04, FR-10  
**Related use case:** UC-01 Process Customer Sale  
**Related Gherkin:** SC-07  
**Related Slice:** Slice 4 — Customer Sale

**Acceptance criteria:**

1. Given a valid sale contains one or more sale lines, when the sale is recorded, then each line retains the information needed to identify the sold item and its maker.
2. Given a sale line includes a discount, when the sale is recorded, then the discount information is retained with the relevant line.
3. Given an item is unavailable for sale, when the sale is submitted, then the system rejects the sale rather than recording an invalid commitment.
4. Given a sale is successfully recorded, then the relevant item must no longer be treated as available for another sale.

**Open questions:**

- Q-06 — How should discounts, deposits, refunds and sale adjustments be represented?
- Q-SH-01 — Can an item be sold to the customer who currently holds its reservation?
- Q-SH-04 — Does quantity represent multiple units or does each itemCode identify one physical unit?

**Links:** CA1 FR-01/FR-04/FR-10, UC-01, SC-07, Slice 4 contracts and design artefacts.

**Status:** Backlog  
**Owner:** Slice 4 owner  

---

## US-CA2-01 — Reconcile Offline Market Transactions

**Type:** User Story  
**Source:** Proposed CA2 extension based on CA1 NFR-05 and offline market constraints  
**Value statement:**

As an authorised Market Coordinator, I want offline market transactions to be recorded and reconciled when connectivity returns so that market sales are not lost or incorrectly recorded.

**Business value:** Supports reliable transaction records during market internet interruptions.

**Priority:** High  
**Related requirement:** NFR-05  
**Related use cases:** UC-01 Process Customer Sale, UC-03 Record Stock Movement and proposed UC-10 Reconcile Offline Transactions  
**Related Slice:** Slice 3 — Offline Transactions

**Acceptance criteria:**

1. Given an offline transaction has been recorded, when it is submitted for reconciliation, then the system must retain the transaction reference and its recorded details.
2. Given a transaction can be reconciled successfully, then the resulting sale must be recorded through the agreed sales-recording process.
3. Given a duplicate or conflicting transaction is identified, then it must not silently create an additional sale or an incorrect stock commitment.
4. Given a transaction cannot be safely reconciled, then it must remain identifiable for further review.

**Open questions:**

- Q-08 — What offline procedure, reconciliation authority and conflict handling are required?
- Q-SH-02 — What should happen when a request is retried after a timeout?
- Q-SH-09 — How should duplicate offline transaction references be identified, if this remains the agreed question identifier?

**Links:** CA1 NFR-05, FR-10, UC-01, UC-03, CA2 UC-10 proposal and Slice 3 design artefacts.

**Status:** Backlog — group validation required  
**Owner:** Slice 3 owner  

---

# 3. Analysis / Design Tasks

Analysis and Design Tasks produce the technical and analytical artefacts required for the selected use cases.

Each task must identify its purpose, input artefacts, expected output, owner, reviewer and Definition of Done.

## AD-01 — Design Slice 1: Reservation

**Purpose:** Design the reservation functionality and its interactions with stock availability.

**Input artefacts:**
- CA1 UC-02 Manage Reservation.
- FR-04 and FR-05.
- BR-04.
- SC-01, SC-02 and SC-03.
- Reservation-related open questions, including Q-01.
- Shared StockAvailabilityPort and Clock contracts.

**Expected output:**
- Detailed design responsibilities and CRC Cards.
- System sequence diagram and object-interaction sequence diagram.
- Design class diagram contributions.
- Operation contracts and relevant result/error conventions.
- Design rationale and unresolved questions.

**Owner:** Slice 1 owner  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Required design artefacts are present in editable form.
- The reservation lifecycle and stock transitions are represented consistently.
- Design messages agree with operation contracts and class responsibilities.
- Unresolved reservation-policy questions are documented rather than assumed.
- Peer review is recorded and relevant corrections are completed.

---

## AD-02 — Design Slice 2: Customer Order

**Purpose:** Design multi-maker customer order fulfilment with independent order-line states.

**Input artefacts:**
- CA1 UC-04 Manage Customer Order.
- FR-06 and FR-07.
- BR-02 and BR-03.
- SC-04.
- Q-03.
- Shared Clock contract.

**Expected output:**
- CRC Cards.
- System sequence diagram and object-interaction sequence diagram.
- Design class diagram contributions.
- Operation contracts for order-line fulfilment operations.
- Design rationale and unresolved approval questions.

**Owner:** Slice 2 owner  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Each order line has an explicitly modelled fulfilment state.
- Partial fulfilment is represented without incorrectly closing the whole order.
- Substitution and cancellation approval uncertainty is documented.
- Messages, operations and class responsibilities agree.
- Peer review is recorded.

---

## AD-03 — Design Slice 3: Offline Transaction Reconciliation

**Purpose:** Design the process for safely reconciling transactions captured during market connectivity interruptions.

**Input artefacts:**
- CA1 NFR-05.
- CA1 FR-10.
- CA1 UC-01 and UC-03.
- Proposed CA2 UC-10 Reconcile Offline Transactions.
- Q-08 and relevant shared questions.
- Shared StockAvailabilityPort, SaleRecordingPort and Clock contracts.

**Expected output:**
- CRC Cards.
- System sequence diagram and object-interaction sequence diagram.
- Design class diagram contributions.
- Offline transaction and reconciliation operation contracts.
- Conflict, duplicate and retry handling design.
- Design rationale and unresolved questions.

**Owner:** Slice 3 owner  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Normal reconciliation and relevant failure paths are represented.
- Duplicate and conflicting transactions cannot silently create incorrect records.
- The design uses the agreed SaleRecordingPort and StockAvailabilityPort contracts.
- The design does not invent a reconciliation authority or offline policy.
- Peer review is recorded.

---

## AD-04 — Design Slice 4: Customer Sale

**Purpose:** Design customer sale processing, including item availability, maker attribution and sale-line information.

**Input artefacts:**
- CA1 UC-01 Process Customer Sale.
- FR-01, FR-04 and FR-10.
- BR-01.
- SC-07.
- Q-06, Q-SH-01 and Q-SH-04.
- Shared StockAvailabilityPort and Clock contracts.

**Expected output:**
- CRC Cards.
- System sequence diagram and object-interaction sequence diagram.
- Design class diagram contributions.
- SaleRecordingPort operation contract.
- Sale and SaleLine responsibility rationale.
- Design rationale and unresolved questions.

**Owner:** Slice 4 owner  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Sale processing and its rejection paths are represented.
- Maker attribution is retained for every sold item.
- Sale-line adjustments are represented consistently with agreed decisions.
- The stock transition agrees with the shared StockAvailabilityPort contract.
- The design can be used by Slice 3 through the agreed sale-recording interface.
- Peer review is recorded.

---

## AD-05 — Integrate Shared UML Diagrams

**Purpose:** Combine the four individual slice designs into a coherent overall software design.

**Input artefacts:**
- CRC Cards from AD-01 to AD-04.
- Individual sequence diagrams.
- Individual design class contributions.
- Shared interface contracts.
- CA1 domain model and glossary.

**Expected output:**
- One integrated design class diagram.
- Consistent object-interaction diagrams.
- One package/layer view.
- Updated shared interface catalogue.
- Recorded integration decisions.

**Owner:** TBC — group assignment  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Classes and relationships are consistent across all four slices.
- Shared interfaces are represented consistently.
- No unexplained duplicate responsibilities or contradictory operations remain.
- Editable PlantUML source and readable exports are committed.
- Peer review is recorded.

---

## AD-06 — Review CRC Cards and Responsibility Allocation

**Purpose:** Check that class responsibilities and collaborations are clear, cohesive and consistent across the four slices.

**Input artefacts:**
- CRC Cards from all four slices.
- Integrated design class diagram.
- Shared interface catalogue.
- GRASP decision records.

**Expected output:**
- Reviewed CRC Cards.
- Recorded responsibility changes where necessary.
- Identified duplicated or missing responsibilities.
- Updated design rationale.

**Owner:** TBC — group assignment  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Each principal class has clear knowing, doing and collaborating responsibilities.
- Responsibilities are not duplicated without justification.
- Collaborators agree with the actual design interactions.
- Important responsibility decisions are supported by GRASP reasoning.
- Review comments are resolved or documented.

---

## AD-07 — Complete Traceability Matrix

**Purpose:** Maintain traceability between the Product Backlog, CA1 requirements, selected use cases and CA2 design artefacts.

**Input artefacts:**
- Product Backlog.
- CA1 requirements and business rules.
- Gherkin scenarios.
- Selected use cases and SSDs.
- Operation contracts.
- CRC Cards, GRASP records and design diagrams.

**Expected output:**
- Updated traceability matrix.
- Identifiable links between each selected use case and its design evidence.
- Recorded gaps and unresolved traceability issues.

**Owner:** TBC — group assignment  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Every selected use case has a traceability entry.
- Identifiers agree across linked artefacts.
- Missing or uncertain links are visible.
- Repository evidence is linked.
- Peer review is recorded.

---

## AD-08 — Complete CA2 Documentation and Dossier

**Purpose:** Assemble and organise the required project documentation.

**Input artefacts:**
- Scenario selection record.
- Agreed CA1 baseline and change log.
- Product Goal and Product Backlog.
- Four slice design artefacts.
- Shared UML and interface documentation.
- Decision log and open questions.
- Traceability matrix.
- Peer-review and contribution evidence.

**Expected output:**
- Complete CA2 dossier.
- Organised repository documentation.
- Updated README and documentation index.
- Links to editable source artefacts and exported diagrams.

**Owner:** TBC — group assignment  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- Required documentation is present and readable.
- All repository links resolve.
- The dossier and repository describe the same design.
- Contributions and AI declarations are represented truthfully.
- Peer review is recorded.

---

## AD-09 — Final Consistency and Submission Review

**Purpose:** Verify that the final design is complete, internally consistent and ready for submission.

**Input artefacts:**
- All completed backlog items.
- Integrated design artefacts.
- Traceability matrix.
- Definition of Done.
- CA2 submission requirements.

**Expected output:**
- Final review record.
- Resolved or documented review findings.
- Confirmed submission checklist.
- Final `ca2-submission` tag or release.

**Owner:** TBC — group assignment  
**Priority:** High  
**Status:** Backlog

**Definition of Done:**
- All selected use cases have reviewed design evidence.
- Contracts, diagrams, CRC Cards and traceability agree.
- All significant review comments are resolved or documented.
- Required editable files and exports are present.
- The final repository state is tagged or released as required.

---

# 4. Risks and Spikes

Risk and Spike items investigate uncertainties that could affect the design. They must not turn proposed assumptions into confirmed business rules without evidence.

## SPIKE-01 — Clarify Reservation Expiry Policy

**Question:** How long do unpaid and deposited reservations last, and who can approve extensions?

**Reason:** CA1 does not establish a universal reservation duration. Slice 1 needs an approved policy or a clearly defined policy boundary.

**Time limit:** One focused group investigation session; target 60 minutes.

**Evidence sought:**
- CA1 Q-01.
- Any available scenario or stakeholder clarification.
- Manager's decision, if obtained.
- Impact on ReservationPolicy and Clock responsibilities.

**Decision/result:** Pending. No expiry duration is treated as approved.

**Affected artefacts:** UC-02, ReservationPolicy, reservation contracts, CRC Cards and sequence diagram.

**Owner:** Slice 1 owner  
**Priority:** High  
**Status:** Backlog

---

## SPIKE-02 — Clarify Stock Item Identity and Quantity

**Question:** Does each itemCode identify one physical unit, or can it represent multiple interchangeable units or a batch?

**Reason:** The CA1 domain model distinguishes Product from StockItem, while the CA2 sale contract contains both itemCode and quantity. Their meaning must be consistent.

**Time limit:** One focused group investigation session; target 60 minutes.

**Evidence sought:**
- CA1 Q-02.
- CA1 Product and StockItem model.
- CA2 SaleRequest and SaleLine contracts.
- Q-SH-04.
- Examples involving one-off and interchangeable craft products.

**Decision/result:** Pending. No item-identity or quantity convention is assumed to be approved.

**Affected artefacts:** Domain model, sale contract, stock availability contract, CRC Cards and traceability matrix.

**Owner:** Slice 4 owner  
**Priority:** High  
**Status:** Backlog

---

## SPIKE-03 — Clarify Offline Reconciliation Authority and Conflicts

**Question:** Who is authorised to reconcile offline transactions, and how should conflicting or duplicate transactions be handled?

**Reason:** CA1 NFR-05 identifies offline recording and later reconciliation as necessary, but detailed authority and conflict policies remain unresolved.

**Time limit:** One focused group investigation session; target 60 minutes.

**Evidence sought:**
- CA1 Q-08.
- NFR-05.
- Proposed UC-10.
- Slice 3 operation contracts.
- Shared SaleRecordingPort and StockAvailabilityPort contracts.

**Decision/result:** Pending. No reconciliation authority or conflict policy is treated as approved.

**Affected artefacts:** UC-10, Slice 3 sequence diagram, CRC Cards, operation contracts and decision log.

**Owner:** Slice 3 owner  
**Priority:** High  
**Status:** Backlog

---

## SPIKE-04 — Review Sale Adjustments and Transaction Evidence

**Question:** How should discounts, deposits, refunds and other sale adjustments be represented in transaction evidence?

**Reason:** CA1 identifies these adjustments as important for maker reconciliation, but their detailed treatment is unresolved.

**Time limit:** One focused group investigation session; target 60 minutes.

**Evidence sought:**
- CA1 FR-10.
- CA1 Q-06.
- Sale and SaleLine domain concepts.
- Current SaleRequest contract.

**Decision/result:** Pending. No financial calculation or accounting policy is invented.

**Affected artefacts:** Sale, SaleLine, sale operation contract, Slice 4 CRC Cards and traceability.

**Owner:** Slice 4 owner  
**Priority:** High  
**Status:** Backlog

---

## SPIKE-05 — Verify Shared Contract Compatibility

**Question:** Do the shared interfaces provide the operations and result information needed by all four slices without conflicting responsibilities?

**Reason:** Slice 1, Slice 3 and Slice 4 depend on stock availability, while Slice 3 also depends on sale recording.

**Time limit:** One focused group interface-review session; target 60 minutes.

**Evidence sought:**
- StockAvailabilityPort contract.
- SaleRecordingPort contract.
- Clock contract.
- Slice-specific operation contracts and sequence diagrams.

**Decision/result:** Pending group review. Any accepted convention must be recorded in the decision log.

**Affected artefacts:** Shared interface catalogue, package diagram, operation contracts and design class diagram.

**Owner:** TBC — group assignment  
**Priority:** High  
**Status:** Backlog


