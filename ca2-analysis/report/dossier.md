# CA2 Group Design Dossier
## Local Craft Marketplace — Kerry Makers Cooperative

| Submission information | Details |
|---|---|
| Module | [Official module title and code] |
| Assessment | CA2 — Collaborative Object-Oriented Design |
| Group members | [Full names and student numbers of the four members] |
| Repository | [LocalCraftMarketplace](https://github.com/Mykola-Rubliuk/LocalCraftMarketplace) |
| Submission tag | `ca2-submission` |

---

## 1. Product Goal

CA2 keeps the outcome already agreed in the [Product Goal](product-goal.md): enable authorised Kerry Makers Cooperative staff to maintain accurate records of products, stock availability, reservations, multi-maker order fulfilment and sales, including controlled reconciliation of offline market transactions. The value is fewer conflicting commitments, better visibility of order progress, reliable maker evidence, and confidential data staying restricted to authorised users.

This follows the CA1 finding that spreadsheets, handwritten notes and messages were fragmenting the cooperative's records. CA2 narrows that down to a design for specific behaviours, not a different problem. The system supports staff; it doesn't replace production, collection or payment. Accurate records of commitments and transactions remain the measure of success.

## 2. Scenario Selection and Agreed Baseline

The group weighed Local Craft Marketplace against Renewable Energy Maintenance. Both gave room to model entities, states and exceptions; the maintenance scenario was more self-contained, but marketplace split more naturally into related workflows whose complexity could be managed by picking a few behaviours rather than every CA1 process.

Marketplace won because its workflows genuinely depend on each other: a reservation changes availability; a sale changes the same availability while preserving maker attribution; an order holds lines progressing at different speeds; an offline transaction can't be treated as an ordinary sale without checking existing commitments first. These dependencies give real responsibility allocation and contract-based consistency to design around, and they split sensibly across four contributors who still have to collaborate on one system.

The [scenario-selection record](scenario-selection.md) carries the full comparison and approval of the four-slice scope. The [baseline change log](baseline-change-log.md) records UC-10 confirmed in scope through PB-01, reviewed with the lecturer — that's the repository's account of approval, with no separate signed confirmation included or claimed. The [agreed baseline restatement](agreed-baseline.md) indexes which CA1 actors, requirements, rules, assumptions and use cases are retained.

The change log also standardises the CA1 use-case names and settles `saleRef` as the name for a successful sale result — consistent identifiers across slice boundaries avoid exactly the ambiguous traceability that's easy to introduce by accident. Scope approval and policy approval are separate things, though: reservation duration, item-quantity semantics, approval evidence and persistence mechanism are still open. Nothing here invents stakeholder answers to close those gaps.

## 3. Selected CA2 Design Scope

Four use cases carry the CA2 work, chosen for business value, design complexity, and giving each member a substantial slice. Reservation and sale both touch shared stock; offline reconciliation exercises the same sale capability under less predictable conditions; order fulfilment shows an aggregate deriving status from independently changing lines. The common thread is accuracy of commitments and their evidence, not four unrelated subsystems.

| Slice / canonical use case | Stakeholder value | Requirements / rules | Dependencies and selection reason |
|---|---|---|---|
| 1 — UC-02 Manage Reservation | Avoid incompatible promises, preserve reservation terms | FR-04, FR-05; A-01/A-02 | StockAvailabilityPort, Clock, CurrentUser, ReservationPolicy; time and availability invariants |
| 2 — UC-04 Manage Customer Order (fulfil order lines) | Make partial progress and customer decisions visible | FR-06 context, FR-07; BR-02, BR-03; A-04 | Clock, CurrentUser; existing orders, line states, accountable changes; aggregate behaviour |
| 3 — UC-10 Reconcile Offline Transactions | Prevent loss and duplicate recording of offline sales | FR-13, NFR-05; A-08/A-10, BR-01, BR-05 | StockAvailabilityPort, SaleRecordingPort, Clock, CurrentUser; cross-slice failure and retry behaviour |
| 4 — UC-01 Process Customer Sale | Record valid sales with maker-attributable evidence | FR-01, FR-04, FR-10; BR-01 | StockAvailabilityPort, ProductCatalogue, Clock, CurrentUser; atomic sale recording |

The brief and the rubric describe scope differently — one to three significant use cases versus three to five substantial ones. Four sits inside the rubric's range and matches the four-member split.
UC-04, as drafted, is narrowed to fulfilling existing orders rather than designing order creation itself — FR-06 gives structural context, FR-07 is the actual target. Public e-commerce, payments, accounting, delivery integration and automatic offline sync stay out of scope. The integrated class model covers all four slices.

## 4. Behavioural Design

### 4.1 Slice 1 — UC-02 Manage Reservation

A Shop Volunteer responds to a request to reserve an item. `recordReservation(itemCode, customerRef, conditions)` validates the input, checks stock status, and looks for an existing active reservation. Clock supplies the time; ReservationPolicy determines expiry. On success, a Reservation is created — reference, customer, conditions, Active status, agreed expiry, and the creating volunteer's ID from CurrentUser — and the item moves from Available to Reserved.

The success guarantee ties FR-05's reservation evidence to FR-04's availability rule: a reservation without reserved stock, or reserved stock without a reservation, is inconsistent either way, and both updates need one consistency boundary.

`evaluateExpiry(asOf)` pulls active reservations and compares expiry to the supplied time. An eligible reservation becomes Expired and releases its stock only if nothing else holds it — a repeat evaluation shouldn't redo an already-completed transition, which "Evaluate an expired reservation more than once" tests directly.

One refusal still needs tightening in the use case. The contract limits `ItemUnavailable` to cases without a conflicting active reservation, and the reserve interaction checks for that conflict first, giving `ConflictingReservation`. The use case, however, still lists the availability check before the conflict check, and its alternative flow gives `ItemUnavailable` for any Reserved item. The three-working-day examples in the Gherkin are test data, not an approved universal policy.

Both operations have contracts and appear in the SSD, and the interaction diagrams use the shared stock-method names, with expiry calculation assigned to ReservationPolicy. Two alignment points remain: the reserve interaction calls `rollbackReservation`, which ReservationRepository doesn't define; and technical failures aren't signalled consistently — the class model defines `ReservationTechnicalFailure`, the SSD and reserve interaction return `Rejected`, and the expiry interaction always returns the expired list.

**Evidence:** [Use case](../slices/slice-1/use-case.md), [Gherkin](../slices/slice-1/features/reservation.feature), [SSD](../slices/slice-1/ssd/ssd.puml), [contract](../slices/slice-1/contracts/contract.md), [reserve interaction](../slices/slice-1/sequence/Reserve-Item.puml), [expiry interaction](../slices/slice-1/sequence/Expiry-evaluation.puml).

### 4.2 Slice 2 — UC-04 Manage Customer Order (Fulfil Order Lines)

A Shop Volunteer records a line's progress once an item is finished, collected, or affected by a customer decision — the Maker finishes the item, the Customer approves changes offstage, neither needing a login. The order and lines already exist; FR-07 and BR-03 require each line's state to stay distinguishable, while BR-02 explains why different lines can belong to different makers.

The SSD lists `viewOrder`, `markReady`, `recordCollection`, and `recordCustomerDecision`. Viewing exposes overall and line-level status; a progress call touches only its own line; a customer-decision call records a substitution or cancellation and its reason. The order becomes Completed only once every line is closed — BeingMade moves to Ready, Cancelled or Substituted; Ready moves to Collected, Cancelled or Substituted; those three are closed states, so Completed means every line reached closure, not that every item was actually collected.

D-CA2-14 covers offstage approval and last-change accountability; D-CA2-15 requires a predefined decision reason, including `NotGiven`. A missing reason produces `Rejected(ReasonNotSupplied)`; an invalid transition produces `Rejected(InvalidStatusChange)` with no state change. Both decisions are still marked Draft in the decision log — manager reversion and an editable reason list are future extensions, not current scope.

OrderFulfilmentService coordinates the four operations. For a line change, it takes the Volunteer's ID from CurrentUser (D-CA2-20) and the time from Clock, and OrderLine records both as the last change. OrderLine enforces its own transitions, CustomerOrder derives its status from its lines, and CustomerOrderRepository finds and saves orders. Access is checked before the use case starts.

**Evidence:** [Use case](../slices/slice-2/use-case.md), [Gherkin](../slices/slice-2/features/order-fulfilment.feature), [SSD](../slices/slice-2/ssd/ssd.puml), [contracts](../slices/slice-2/contracts/operation-contracts.md), [state machine](../slices/slice-2/state/order-line-state.puml); object interactions for [view](../slices/slice-2/sequence/view-order.puml), [ready](../slices/slice-2/sequence/mark-ready.puml), [collection](../slices/slice-2/sequence/record-collection.puml) and [customer decision](../slices/slice-2/sequence/record-customer-decision.puml). Decisions D-CA2-14–17 and D-CA2-20. CA1 [SC-04](../../ca1-analysis/features/marketplace.feature) and CA2 PB-05/US-02 give the baseline links.

### 4.3 Slice 3 — UC-10 Reconcile Offline Transactions

Offline market forms get filled in by hand during outages. Once connectivity returns, a Market Coordinator enters them, and the system validates the offline reference, sale date, items and prices. Each entry gets a unique internal `entryId`; `offlineRef` is kept as business evidence and can legitimately repeat on a duplicate form, while `submissionId` tells a retry apart from a genuinely new entry sharing a reference.

A fresh entry starts AwaitingReconciliation; a repeated reference goes straight to ReferredToManager. During reconciliation, ConflictChecker checks every line for duplicates and stock status — a Sold, Reserved or Unknown item blocks the whole offline sale. A clean record produces one `SaleRequest` through SaleRecordingPort, and only `Recorded(saleRef)` lets it become Reconciled; the sale service, not the reconciliation controller, actually creates the sale.

CurrentUser supplies who entered the form, the processor stored in a new SaleRequest (kept unchanged on retries) and who resolved a referral. The Manager reviews referred records and logs a decision, a note, who made it and when; status becomes Resolved without an automatic sale — keeping exception-handling separate from payment correction, which stays outside the system. "Refer a duplicate offline transaction" and "Manager resolves a referred offline transaction" show the accountability goal behind FR-13 and NFR-05.

A technical failure isn't a business conflict — a timeout doesn't prove a sale failed. The design stores the `SaleRequest` before the first sale attempt, reuses it with `entryId` as the idempotency key, and leaves the entry AwaitingReconciliation after a technical failure. It calls `findRecordedResult` before any duplicate or stock check, so a sale that succeeded earlier is recovered instead of its Sold stock being treated as a fresh conflict. This is designed behaviour, not something implemented here.

The class model, SSD and operation contracts all identify reconciliation and resolution by `entryId`, and use `saleRef` for a successful sale result. Only `reconcile` has a separate object interaction diagram; entry and resolution don't.

**Evidence:** [Use case](../slices/slice-3/use-case.md), [Gherkin](../slices/slice-3/features/offline-reconciliation.feature), [SSD](../slices/slice-3/ssd/ssd.puml), [contracts](../slices/slice-3/contracts/operation-contracts.md), [object interaction](../slices/slice-3/sequence/sequence.puml).

### 4.4 Slice 4 — UC-01 Process Customer Sale

A Shop Volunteer, or a Market Coordinator at an event, records an agreed purchase. `recordSale(request: SaleRequest): SaleRecordingResult` takes an idempotency key, processor, channel, optional customer/source references, a sale date where relevant, and one or more lines with item code, quantity, sold price and optional discount.

SaleService validates the request, checks idempotency, resolves product and maker details through ProductCatalogue, and checks stock for every line. Only once all lines pass does it create the Sale and SaleLine objects and coordinate the all-or-nothing stock transition; SaleRepository keeps the sale and its idempotency result. Success returns the unique `saleRef` and confirms Completed/Sold status.

Each line keeps maker attribution and the actual transaction amounts rather than relying on current list price — that's what makes BR-01 and FR-10 real evidence instead of a snapshot that could drift. FR-04 follows from making sold items unavailable for any other commitment. For offline purchases, the historical `saleDate` stays distinct from `recordedAt`. For a new in-store sale, `processedBy` must also match the signed-in user's ID from CurrentUser.

"Record a sale containing items from two makers" shows the normal path; "Reject the entire sale when one item is unavailable" establishes that one bad line can't leave a partial sale behind. Other refusals: NoLines, ItemNotFound, MissingMakerAttribution, bad monetary values, bad quantities, unauthorised processing. Reserved items currently aren't sellable under the shared convention — pending the still-open reservation-holder policy.

The idempotency contract needs the original result returned for a repeated key and payload, and rejection for a different payload reusing the same key. The class diagram source stores a request fingerprint in `IdempotencyRecord` for that comparison, but its SaleRepository operations don't yet match the names and parameters in the diagram description and the Slice 4 CRC cards and sequence. The processor identity is only partly verified: the in-store match doesn't cover offline requests, whose origin isn't checked (Q-SH-12), or whether the signed-in user may retry a request or see its saved result (Q-SH-13). Live market sales also lack their own channel (Q-SH-14). The provider's atomic stock transition also doesn't by itself guarantee atomicity across sale repository and stock storage — the contract states the guarantee; nothing here proves an implementation delivers it.

**Evidence:** [Use case](../slices/slice-4/use-case.md), [Gherkin](../slices/slice-4/features/customer-sale.feature), [SSD](../slices/slice-4/ssd/ssd.puml), [contract](../slices/slice-4/contracts/operation-contracts.md), [object interaction](../slices/slice-4/sequence/sequence.puml).

## 5. Responsibility and Object Design

The [integrated class diagram](../design/integrated-design-class-diagram.puml) and its [description](../design/integrated-design-class-diagram.md) lay out the four-slice model and how messages map to operations.

### 5.1 Principal CRC responsibilities

This picks out main responsibilities rather than every card.

| Class / capability | Principal responsibility | Collaborators |
|---|---|---|
| ReservationService | Coordinate reservation and expiry operations | Reservation, ReservationPolicy, ReservationRepository, StockAvailabilityPort, Clock, CurrentUser |
| Reservation | Retain customer, item, conditions, status, expiry and creator | ReservationService, ReservationRepository |
| ReservationPolicy | Calculate agreed expiry from policy | ReservationService; calendar policy |
| OrderFulfilmentService | Coordinate order lookup and line changes | CustomerOrder, CustomerOrderRepository, Clock, CurrentUser |
| CustomerOrder / OrderLine | Retain lines, line status and derived order progress; record decisions | Each other |
| OfflineReconciliationService | Coordinate entry, conflict checks, reconciliation and manager resolution | OfflineTransaction, ConflictChecker, repository, SaleRecordingPort, Clock, CurrentUser |
| OfflineTransaction | Retain form details, lifecycle, referral and resolution evidence | OfflineLine, controller, repository |
| ConflictChecker | Detect duplicate references and unavailable items | OfflineTransactionRepository, StockAvailabilityPort |
| SaleService | Validate, coordinate and record a sale through the shared port | Sale, SaleLine, ProductCatalogue, SaleRepository, stock port, Clock, CurrentUser |
| Sale / SaleLine | Own transaction and line evidence; calculate monetary totals | Each other, controller, catalogue entities |

### 5.2 Significant GRASP decisions

**Controller — application services (D-CA2-01).** ReservationService, OrderFulfilmentService, OfflineReconciliationService and SaleService each receive the system events for their own use case. Letting entities coordinate their own repositories and stock access would tangle domain objects with infrastructure; one generic controller would just centralise unrelated workflows. Use-case controllers keep the coordination path explicit and leave entities focused on their own state.

**Information Expert — Reservation and ReservationPolicy (D-CA2-05).** Reservation knows its own expiry and status; ReservationPolicy knows how to calculate a new one under the agreed rules. Calendar arithmetic inside ReservationService would mix policy with orchestration, and a policy change would ripple into an otherwise stable use case. (The shared catalogue limits Clock to `now()`, and the Slice 1 GRASP table now matches; the Slice 1 README still credits Clock with working-day calculations.)

**Information Expert — OrderLine and CustomerOrder (D-CA2-06).** Line independence argues for keeping each line's status and valid transitions with the line itself, while the order derives completion from its lines. A single order-level status would hide partial readiness. The Slice 2 CRC cards, GRASP table and sequences apply this allocation; it is design evidence, not an implementation.

**Creator and Information Expert — OfflineReconciliationService and OfflineTransaction.** The controller holds the initial form data, so it creates the OfflineTransaction and OfflineLine objects; the entity then owns its own lifecycle through `markReconciled`, `refer` and `resolve`. A repository that also decided state would mix storage with business logic.

**Pure Fabrication and High Cohesion — ConflictChecker.** Spotting a duplicate needs stored references; spotting an item conflict needs stock data — neither belongs naturally to one offline line. A dedicated checker groups the rules and keeps them independently testable.

**Information Expert — Sale and SaleLine.** A line calculates its own net amount from its own quantity, price and discount; Sale derives the total from its lines. Putting that arithmetic in SaleService instead would separate calculation from data and bloat the controller every time a rule changes. ProductCatalogue keeps product/maker lookup separate from the sale workflow.

**Pure Fabrication — repositories.** ReservationRepository, CustomerOrderRepository, OfflineTransactionRepository and SaleRepository concentrate persistence so domain objects don't need to understand storage. The trade-off: this doesn't by itself guarantee a transaction boundary where repositories and stock storage must change together.

**Indirection and Protected Variations — shared ports (D-CA2-03/04/08).** StockAvailabilityPort gives one shared stock vocabulary; SaleRecordingPort gives one sale-recording boundary. Letting Slice 3 create sales or touch stock directly would duplicate validation and risk inconsistent outcomes. Shared interfaces let fakes be tested against one common contract; Clock applies the same idea to time, and CurrentUser to the signed-in user's identity (D-CA2-20), so no slice depends on how sign-in works.

### 5.3 Integrated collaboration

Slice 1 reserves or releases stock; Slice 3 checks stock and hands off sale recording; Slice 4 creates sales and drives the Sold transition. Slice 2 manages order lines without using the stock or sale ports, and doesn't define collection as a sale. All four share Clock and CurrentUser.

**CRC and GRASP evidence:** [Slice 1](../slices/slice-1/crc/crc.md)/[GRASP](../slices/slice-1/grasp/grasp.md); [Slice 2](../slices/slice-2/crc/crc.md)/[GRASP](../slices/slice-2/grasp/grasp.md); [Slice 3](../slices/slice-3/crc/crc.md)/[GRASP](../slices/slice-3/grasp/grasp.md); [Slice 4](../slices/slice-4/crc/crc.md)/[GRASP](../slices/slice-4/grasp/grasp.md).

## 6. Design Structure and Shared Interfaces

The [package/layer view](../design/package-layer-view.puml) abstracts the class diagram into application services, domain concepts, shared contracts, and persistence/time-provider boundaries — a new view over the existing design, not an implemented deployment. This view has not yet been updated: it still shows order fulfilment as intended design and omits CurrentUser.

Application services coordinate domain objects and repositories; shared abstractions isolate cross-slice dependencies. Concrete database, stock and time providers stay unspecified.

| Shared interface | Operations / result | Responsibility |
|---|---|---|
| StockAvailabilityPort | `getStatus`, `reserveIfAvailable`, `releaseIfReserved`, `sellAllIfAvailable` | Consistent stock status and controlled transitions |
| SaleRecordingPort | `recordSale(SaleRequest)` → `Recorded(saleRef)` / `Rejected(reason)` | One authoritative sale boundary; provided by SaleService |
| Clock | `now(): DateTime` | Supply time without embedding the system clock in business rules |
| CurrentUser | `getUserId(): String` | Supply the signed-in user's identity; not authorisation |

Available, Reserved, Sold and Unknown are the shared stock statuses, and Unknown isn't Available — a stock-service failure is a technical error, not an availability value. Refusals are named consistently; Slice 3's referral reasons explain why a record needs management review rather than signalling infrastructure failure.

The error catalogue keeps refusal and technical failure apart so callers respond to each correctly — a technical failure must never be read as confirmation, and the stock port has to re-check availability on every change since an earlier read can go stale.

The [shared interface catalogue](../design/shared-interface-catalogue.md) and [error catalogue](../design/operation-error-catalogue.md) hold the full definitions; the [shared contract test plan](../design/shared-contract-test-plan.md) specifies tests for status transitions, idempotency, maker attribution and cross-slice interaction — a specification, not executed results. CurrentUser gives all four slices one source for the signed-in user's identity (D-CA2-20); it doesn't define sign-in or authorisation rules.

## 7. Traceability

The [CA2 traceability matrix](../backlog/traceability.csv), prepared alongside this dossier, connects each use case to its backlog item, CA1 requirement, Gherkin, SSD, contract, responsibility artefacts, interactions and classes. The CA1 matrix is untouched; each CA2 row links its design artefacts and records the gaps that remain.

| Use case | CA2 work | CA1 evidence | Design coverage in supplied material |
|---|---|---|---|
| UC-02 | PB-04 / AD-01 / US-01 | TR-02; SC-01–03 | Behaviour, SSD, contracts, CRC/GRASP and interactions present; rollback, failure signalling and refusal precedence need alignment |
| UC-04 | PB-05 / AD-02 / US-02 | TR-04; SC-04 | Use case, Gherkin, SSD, state machine, contracts, CRC/GRASP and interactions present |
| UC-10 | PB-06 / AD-03 / US-CA2-01 | TR-10; US-09; SC-11–15 | Principal artefacts present; no separate interactions for entry or resolution |
| UC-01 | PB-03 / AD-04 / US-05 | TR-07; SC-07 | Principal artefacts present; atomicity, repository operation alignment and processor verification outstanding |

This establishes why an operation exists and how its effects get checked — not that it's implemented or running correctly. FR-06 is context for Slice 2, not a claim order creation is designed; US-CA2-01 links back to its CA1 predecessor US-09 rather than treating offline reconciliation as unrelated new work. Gaps are named explicitly so finishing PB-09 stays a concrete task, not something quietly assumed done.

## 8. Design Evaluation

The design's biggest strength is keeping coordination separate from domain state: controllers make each use case's sequencing readable, while Reservation, OfflineTransaction, Sale and SaleLine still carry real business responsibility instead of becoming data holders. A line-level order model similarly captures independent progress better than one order-wide status would — high cohesion without a separate service for every small calculation.

Shared stock and sale contracts cut coupling: Slice 3 leans on the same sale-recording capability as the ordinary sale flow, avoiding duplicated maker-attribution and stock-update logic. The cost is that those interfaces now have to stay semantically stable — a renamed method, or a different read of "Unknown" stock, can break integration even when each slice looks fine alone. That's why shared contract tests matter, including against any fake provider a member is using.

Object validity depends on state transitions holding together and persistence backing them up. A reservation has to agree with the stock status it produces; a valid Sale needs lines with maker attribution, and one failed line can't leave the rest sold. The class diagram describes these responsibilities, but independent calls to stock and sale storage aren't enough on their own to guarantee atomicity — that needs a shared transaction or recovery protocol at implementation time. This is probably the design's most significant consistency limitation right now.

Idempotency needs more than a unique key: the provider needs enough stored context to tell an identical retry apart from a changed request, and reconciliation needs to recover a prior result rather than treating an already-Sold item as a fresh conflict. The design now covers both, through a stored request fingerprint and a recovery lookup, although `findRecordedResult` appears in the class diagram and Slice 3 but not in the shared interface catalogue or Slice 4's own artefacts. Similarly, CurrentUser now gives `recordedBy`, `resolvedBy` and reconciliation's `processedBy` a common identity source, but it doesn't decide authorisation, and a direct sale request's `processedBy` is compared only for new in-store sales (Q-SH-12, Q-SH-13).

Some trade-offs are deliberate rather than oversights. The reservation policy is configurable instead of a hard-coded three-day window. Reserved stock is conservatively excluded from ordinary sales until the reservation-holder question is settled. What one unit of stock actually is, and what "quantity" means, stays important because a single Sold flag is awkward against a partially sold batch. The order-fulfilment design keeps only the last change rather than full history, and offstage approval can't be verified by the system itself — manageable trade-offs, but real operational risk.

The evidence supports a coherent direction, not a claim that every rule is confirmed or every sequence lines up. Fixing the remaining mismatches, walking through exceptional scenarios, and getting actual reviews done matter more right now than adding classes. The [open questions](../decisions/open-questions.md) remain the right place to track unresolved policy and integration risk.

## 9. Process, Review and Individual Evidence

The [Product Backlog](../backlog/product-backlog.md) gives work identifiers and a proposed split into four slice owners plus shared integration tasks. The [iteration plan](../project-management/iteration-plan.md) sequences work from baseline agreement through contracts, slice design, integration and final evidence. The [Definition of Done](../project-management/definition-of-done.md) asks for editable sources, aligned terminology, traceability, actual peer review, updated evidence links, and AI disclosure before anything counts as complete.

The [decision log](../decisions/decision-log.md) records alternatives and rationale. In its current snapshot, PB-01 and PB-02 are Ready, the four slice tasks are In Progress, and integration/review/submission work is still Backlog — recorded statuses, not a live verified board. The [peer review template](../reviews/peer-review-template.md) sets out how review should be recorded. The [integration review](../reviews/integration-review.md) records document-level findings for Slices 1, 3 and 4, including a Slice 4 self-review, with some changes still requested; it states that these are not formal peer approval. It doesn't review Slice 2 and doesn't record a review of the later CurrentUser changes.

GitHub history, board activity, finished reviews. 
Each member needs to record their actual contributions and reviews, referencing real commits or pull requests. 
The group AI declaration and individual logs need to describe the tools used, their purpose, what they touched, and how a human checked the result
— honestly, not as a formality.
The final submission tag needs to point at the reviewed state, not just be mentioned here.
## Repository references and evidence notes

- [CA1 analysis dossier](../../ca1-analysis/report/analysis_dossier.md), [CA1 user stories](../../ca1-analysis/requirements/backlog.md), [domain model](../../ca1-analysis/diagrams/domain-model.puml), [CA1 traceability](../../ca1-analysis/requirements/traceability.csv).
- [CA2 README](../README.md), [scenario selection](scenario-selection.md), [baseline change log](baseline-change-log.md), [baseline restatement](agreed-baseline.md).
- [Integrated class diagram](../design/integrated-design-class-diagram.puml), [package/layer view](../design/package-layer-view.puml), [traceability matrix](../backlog/traceability.csv), [shared test plan](../design/shared-contract-test-plan.md).