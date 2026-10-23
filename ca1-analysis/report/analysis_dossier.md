
# CA1: Individual Requirements and Domain Analysis
## Evidence convention

**E** = directly supported by the supplied scenario
**A** = proposed assumption requiring confirmation
**Q** = clarification question
**D** = analyst's proposed design/analysis decision. 
A requirement can be proposed on the basis of evidence without implying that the detailed business policy has been confirmed. 
This report analyses marketplace coordination, not an implemented application.

## 1. Scenario Interpretation

### 1.1 Organisation and present process

Kerry Makers Cooperative is a shared marketplace for independent makers of ceramics, textiles, woodwork, prints, jewellery and other craft products. 
The cooperative sells goods in a small shop, at seasonal markets and through customer enquiries received by telephone or email. 
Makers supply standard products, one-off pieces and commissioned items. Products can differ in materials, colour, finish, dimensions and care needs. 
Stock may be held at the shop, retained by a maker, reserved for an event or removed for display.

The present process relies on spreadsheets, handwritten sales books and messages. 
Staff use these separate records to manage product descriptions, stock, orders, sales and amounts attributable to makers. 
Updates are not consistently reflected across locations. A single customer order can contain items from several makers, 
with some ready immediately and others reserved or commissioned. Customers may collect items at the shop or market or receive local delivery. 
Staff must check that each item is present, correctly priced and attributed to the right maker.

### 1.2 Problems, evidence and consequences

| ID     | Scenario evidence                                                                                 | Business problem                             | Potential consequence                          |
|--------|---------------------------------------------------------------------------------------------------|----------------------------------------------|------------------------------------------------|
| P-01   | Quantities and locations are not consistently updated, 'available' may not mean available in shop | Unreliable availability information          | Staff promise an item that cannot be supplied  |
| P-02   | One-off pieces may differ from a standard design; staff disagree about individual records         | Ambiguous item identification                | Unique pieces may be confused or counted twice |
| P-03   | Reservations vary; some are pending payment or deposit                                            | Inconsistent reservation control             | Unclear stock commitments and missed sales     |
| P-04   | Mixed-maker orders may be partly ready; customer decisions are not consistently recorded          | Incomplete order-level and item-level status | Customer and staff disagree about fulfilment   |
| P-05   | Commission changes and approvals appear in separate messages                                      | Weak change history                          | Disputes about agreed materials, price or date |
| P-06   | Returns, repairs and exchanges have inconsistent recording                                        | Missing after-sales history                  | Unclear outcome and difficult follow-up        |
| P-07   | Discounts, deposits and refunds complicate maker reconciliation                                   | Incomplete transaction evidence              | Amounts attributable to makers may be wrong    |
| P-08   | Volunteers should not see all maker-payment details, markets have unreliable internet             | Access and connectivity constraints          | Privacy exposure or delayed records            |

### 1.3 Desired outcomes

The desired outcome is a consistent record of each product or distinguishable item, its current location and availability, and the commitments affecting it. 
Staff should be able to understand the progress of each order line, document commission changes and customer decisions, and record returns and sales evidence.
The manager should be able to review operational exceptions and maker-attributable amounts without exposing confidential payment information to volunteers. 
Market activities must remain workable during internet interruptions, with a reliable later reconciliation process.

### 1.4 Known evidence and uncertainty

The scenario confirms that these problems and operational activities exist, but does not establish reservation durations, a universal unique-item policy, 
approval authority, return eligibility, maker fee calculations or detailed permissions. 
Accordingly, proposed rules are explicitly labelled A-01 to A-09 and linked to clarification questions Q-01 to Q-08. 
No assumption is treated as an approved business rule.

## 2. Purpose, Scope and Boundary

### 2.1 Purpose

The proposed Local Craft Marketplace System aims to improve coordination and evidence for products, stock, reservations, customer orders, commissions, 
after-sales cases and maker-attributable transactions. Its purpose is to make records consistent across sales channels and locations and support staff decisions, 
rather than replace physical craft production or introduce public online selling.

### 2.2 In scope

The initial system covers product and unique-item identification, stock holdings and movements, availability and reservations,
multi-maker orders with line-level fulfilment, commission specifications and proposed changes, sales, discounts, deposits,  
returns, repairs and exchanges as recorded cases; operational reports and role-restricted access. 

### 2.3 Out of scope

Public e-commerce, online payment processing and full accounting are expressly excluded by the scenario. 
Manufacture, physical transport, professional quality certification and legal adjudication of consumer rights are also outside 
the information system's responsibility. The system can record that delivery or inspection occurred without carrying out the physical task.

### 2.4 System boundary and external interactions

Within the boundary are records and business actions carried out by authorised users. 
Shop Volunteer, Manager and Market Coordinator are direct actors. 
For this revised model, **Maker access to the internal system is a proposed assumption**: a Maker can maintain only their own product records, 
subject to role permissions. This is not confirmed by the scenario and must be checked through Q-07. Customer remains an offstage stakeholder. 
No public customer login or e-commerce is proposed. Any external payment provider remains outside the system boundary.

### 2.5 Dependencies, assumptions and constraints

The quality of records depends on stock movements and sales being recorded promptly, 
Makers maintaining accurate details for their own products under the proposed access assumption, and the Manager approving operational policies. 
Key constraints are unreliable market connectivity, different stock locations, restricted access to maker financial data, and exclusion of payment processing 
and full accounting. Proposed policies are maintained in the uncertainty register, not silently embedded in the boundary definition.

## 3. Stakeholder and Actor Catalogue

### 3.1 Stakeholders

| ID    | Stakeholder                  | Classification                                                              | Goal                                                                             | Concern                                           | Influence                              |
|-------|------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------|----------------------------------------|
| ST-01 | Cooperative Manager          | Direct                                                                      | Trustworthy stock, orders, commissions and maker summaries                       | Inaccurate reconciliation, unresolved cases       | High: approves policies and priorities |
| ST-02 | Shop Volunteer               | Direct                                                                      | Sell and reserve items accurately                                                | Unclear availability; excessive financial access  | Medium: daily process knowledge        |
| ST-03 | Market Coordinator           | Direct                                                                      | Transfer and sell event stock with correct records                               | Connectivity and stale shop stock                 | Medium: event process knowledge        |
| ST-04 | Maker                        | External stakeholder; proposed internal-system user for own product records | Maintain accurate product details; correct attribution and fair payment evidence | Unique pieces, commission changes, payment errors | High: product and commission rules     |
| ST-05 | Customer                     | External                                                                    | Know item readiness and agreed terms                                             | Delays, substitutions, return outcomes            | Medium: service expectations           |
| ST-06 | Accounting / payment support | Indirect, conditional                                                       | Reliable evidence for reconciliation                                             | Missing discounts, refunds or deposits            | Medium if role exists; confirm Q-06    |

### 3.2 Actors and goals

| Actor              | Type                                     | Goal                                                                                            | Use cases                                             |
|--------------------|------------------------------------------|-------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| Shop Volunteer     | Primary                                  | Record a sale and order decisions; reserve items; open a return case                            | [UC-01, UC-02, UC-04, UC-06](#61-Catalogue)              |
| Market Coordinator | Primary                                  | Record stock transfers and event transactions                                                   | [UC-03, UC-01](#61-Catalogue)                            |
| Manager            | Primary                                  | Coordinate commission decisions; review marketplace operations, maker evidence and return cases | [UC-05, UC-07, UC-09](#61-Catalogue)                     |
| Maker              | Proposed primary actor (assumption A-09) | Maintain own product records and provide input on commission feasibility                        | [UC-05, UC-08](#61-Catalogue)                            |
| Customer           | Offstage stakeholder                     | Request items and approve changes                                                               | Indirectly influences [UC-02/UC-04/UC-05](#61-Catalogue) |

Actor assignments are proposed. 
Maker access is an explicit project assumption (A-09), not a confirmed scenario fact.
Customer remains offstage and has no direct system access in this scope.

## 4. Requirements Catalogue and MoSCoW

MoSCoW means **Must** (essential for the initial system), 
**Should** (important but a manual workaround exists), 
**Could** (desirable), 
and **Won't** (excluded from this release). 

Priorities below are proposed and require manager validation. 

### 4.1 Functional requirements

| ID    | Atomic requirement                                                                                                               | Source and rationale                                               | MoSCoW | Verification                                  | Links                                                           |
|-------|----------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|--------|-----------------------------------------------|-----------------------------------------------------------------|
| FR-01 | The system shall record a product's maker, description and selling price.                                                        | [E](#Evidence-convention): product records include maker and price; consistent attribution | Must   | Create/read record with those fields          | [P-02](#12-Problems-evidence-and-consequences); [UC-08](#61-Catalogue); Product                      |
| FR-02 | The system shall record an identified stock item's current stock location.                                                       | [E](#Evidence-convention): stock is held at different locations                            | Must   | Record and retrieve location                  | [P-01](#12-Problems-evidence-and-consequences); [UC-03](#61-Catalogue); StockItem                                          |
| FR-03 | The system shall record a stock movement with item, origin, destination and event date.                                          | [E](#Evidence-convention): stock moves without shop records changing                       | Must   | Inspect recorded transfer history             | [P-01](#12-Problems-evidence-and-consequences); [UC-03](#61-Catalogue); StockMovement                     |
| FR-04 | The system shall indicate whether a selected item is available for commitment, based on recorded sales and active reservations.  | [E](#Evidence-convention): available counts include sold/reserved items                    | Must   | Test sold, reserved and available examples    | [P-01/P-03](#12-Problems-evidence-and-consequences); [UC-02](#61-Catalogue); StockItem                    |
| FR-05 | The system shall record a reservation linking an item to a customer and its agreed conditions.                                   | [E](#Evidence-convention): reservations vary and may await payment                         | Must   | Create and retrieve reservation               | [P-03](#12-Problems-evidence-and-consequences); [UC-02](#61-Catalogue); Reservation                       |
| FR-06 | The system shall record customer orders containing one or more order lines.                                                      | [E](#Evidence-convention): mixed-maker orders                                              | Must   | Save order with two maker-linked lines        | [P-04](#12-Problems-evidence-and-consequences); [UC-04](#61-Catalogue); Order/OrderLine                                    |
| FR-07 | The system shall record a fulfilment status for each order line independently.                                                   | [E](#Evidence-convention): partial collection, waiting, substitutions                      | Must   | Update one line without changing another      | [P-04](#12-Problems-evidence-and-consequences); [UC-04](#61-Catalogue); OrderLine                         |
| FR-08 | The system shall record agreed commission specifications and their proposed changes.                                             | [E](#Evidence-convention): materials, dimensions, price and dates may change               | Should | Record original terms and a proposed change   | [P-05](#12-Problems-evidence-and-consequences); [UC-05](#61-Catalogue); Commission                        |
| FR-09 | The system shall record a return, exchange or repair case and its outcome.                                                       | [E](#Evidence-convention): after-sales outcomes inconsistently recorded                    | Should | Open, update and retrieve a case              | [P-06](#12-Problems-evidence-and-consequences); [UC-06/UC-09](#61-Catalogue); ReturnCase                  |
| FR-10 | The system shall retain sale transaction evidence identifying the maker and monetary adjustments associated with each sold item. | [E](#Evidence-convention): maker payments affected by discounts, deposits, refunds         | Must   | Reconcile sample item with adjustment records | [P-07](#12-Problems-evidence-and-consequences); [UC-01/UC-07](#61-Catalogue); SaleLine                    |
| FR-11 | The system shall restrict volunteer access to confidential maker payment information.                                            | [E](#Evidence-convention): volunteer should sell without seeing all payment details        | Must   | Authorisation test with volunteer account     | [P-08](#12-Problems-evidence-and-consequences); [UC-07](#61-Catalogue); UserRole                          |
| FR-12 | The system shall produce an operational view of incomplete orders, reservations and commissions for authorised staff.            | [E](#Evidence-convention): manager needs these summaries                                   | Should | Verify each open record appears               | [P-04/P-05](#12-Problems-evidence-and-consequences); [UC-07](#61-Catalogue); Order/Reservation/Commission |

### 4.2 Measurable non-functional requirements

These are **proposed acceptance targets**, not scenario facts. Confirm thresholds and test conditions before implementation.

| ID     | Quality                 | Measurable proposed requirement                                                                                                                                                                  | Priority | Verification and source                                                                                                   |
|--------|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------|
| NFR-01 | Security                | Shop Volunteers shall not be able to view confidential maker-payment records.                                                                                                                    | Must     | Test access using a Volunteer account; [E](#Evidence-convention): volunteer privacy concern                                                          |
| NFR-02 | Performance             | The system shall display recorded stock availability within 3 seconds under normal operating conditions.                                                                                         | Should   | Measure response time during stock-availability checks; [D](#Evidence-convention): proposed target                                                   |
| NFR-03 | Data integrity          | The system shall retain confirmed stock movements and their history after the application is closed and reopened.                                                                                | Must     | Record stock movements, restart the application and verify the records; [E](#Evidence-convention): inconsistent records                              |
| NFR-04 | Usability               | A trained Shop Volunteer shall be able to record a standard customer sale using the system without assistance.                                                                                   | Should   | Observe a trained volunteer completing a standard sale; [D](#Evidence-convention): proposed usability target                                         |
| NFR-05 | Connectivity resilience | The system or an approved offline procedure shall allow market transactions to be recorded during an internet outage and reconciled when connectivity returns, without unaccounted transactions. | Must     | Simulate an outage and verify that recorded transactions can be reconciled; [E](#Evidence-convention): unreliable internet; implementation open Q-08 |

### 4.3 Priority rationale and exclusions

Accurate stock, order-line state, sales evidence and volunteer confidentiality are Must because their absence preserves the core problems. 
Commission change history, return outcomes and operational summaries are Should because controlled manual processes might temporarily support them. 
Automatic promotional recommendations could be Could but are not proposed as a formal requirement because the scenario does not support them. 
Public e-commerce, online payment processing and full accounting are Won't for this release.

## 5. Business Rules and Uncertainty Register

### 5.1 Evidence-supported business rules / policy constraints

These are business-level obligations strongly supported by the scenario, not newly invented durations or financial formulas.

| ID    | Rule                                                                                                              | Evidence / qualification                                                                             | Related requirements                         |
|-------|-------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|----------------------------------------------|
| BR-01 | Every sold item must be attributed to its maker for transaction evidence.                                         | [E](#Evidence-convention): staff must verify maker attribution; sales needed for maker payments                              | [FR-01, FR-10](#41-Functional-requirements)  |
| BR-02 | A customer order may include items supplied by more than one maker.                                               | [E](#Evidence-convention): explicit scenario fact; structural rule                                                           | [FR-06, FR-07](#41-Functional-requirements)  |
| BR-03 | Item-level readiness must be distinguishable within an order.                                                     | [E](#Evidence-convention): customer wants to know which parts are ready or being made                                        | [FR-07](#41-Functional-requirements)         |
| BR-04 | Volunteers must not have access to all confidential maker payment details.                                        | [E](#Evidence-convention): direct volunteer statement                                                                        | [FR-11, NFR-01](#41-Functional-requirements) |
| BR-05 | The system must not perform public e-commerce, online payment processing or full accounting in the initial scope. | [E](#Evidence-convention): explicit scope exclusion; scope constraint rather than operational policy | [Scope 2.3](#23-Out-of-scope)                |

### 5.2 Proposed assumptions

| ID   | Proposed assumption                                                                                                                                                      | Why it is useful                                                                                                | Confirmation          |
|------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|--------------------------|
| A-01 | An unpaid reservation expires after three working days.                                                                                                                  | Gives a testable provisional expiry example                                                                     | [Q-01](#55-Clarification-questions), Manager            |
| A-02 | A deposited reservation may have a separately agreed expiry date.                                                                                                        | Avoids treating deposits as identical to unpaid holds                                                           | [Q-01/Q-06](#55-Clarification-questions), Manager       |
| A-03 | Every one-off physical piece receives a distinct item ID; interchangeable standard stock can share a product type.                                                       | Avoids confusing distinct finishes                                                                              | [Q-02](#55-Clarification-questions), Manager and Maker  |
| A-04 | A customer must approve a substitution or cancellation affecting their order.                                                                                            | Preserves customer choice                                                                                       | [Q-03](#55-Clarification-questions), Manager            |
| A-05 | A material, price or target-date change to a commission requires recorded customer approval.                                                                             | Provides change evidence                                                                                        | [Q-04](#55-Clarification-questions), Manager and Maker  |
| A-06 | Return outcomes are recorded, but eligibility for a refund is decided under an approved policy and applicable law.                                                       | Avoids inventing return rights                                                                                  | [Q-05](#55-Clarification-questions), Manager            |
| A-07 | Manager may view payment summaries; volunteers may record sales but cannot view confidential maker-payment totals.                                                       | Proposed permission interpretation                                                                              | [Q-07](#55-Clarification-questions), Manager            |
| A-08 | Event transactions are captured offline and reconciled by an authorised coordinator when connectivity returns.                                                           | Addresses market outage                                                                                         | [Q-08](#55-Clarification-questions), Coordinator        |
| A-09 | Makers can access the internal system to maintain only their own product records; they cannot edit other Makers' records or access confidential maker-payment summaries. | Gives Makers responsibility for keeping their own product details accurate while preserving access restrictions | [Q-07](#55-Clarification-questions), Manager and Makers |

### 5.3 Constraints

| ID   | Constraint                                                                           | Evidence                  |
|------|--------------------------------------------------------------------------------------|---------------------------|
| C-01 | Internet connectivity can be unreliable at seasonal markets.                         | [E](#Evidence-convention) |
| C-02 | No public e-commerce, online payment processing or full accounting in initial scope. | [E](#Evidence-convention) |
| C-03 | Confidential maker payment information must be restricted from volunteers.           | [E](#Evidence-convention) |
| C-04 | Product and stock information must cover multiple makers, item types and locations.  | [E](#Evidence-convention) |

### 5.4 Risk register

| ID   | Risk                                             | Likelihood / proposed | Question                                                                         |
|------|--------------------------------------------------|-----------------------|-------------------------------------------------------------------------------------|
| R-01 | Incorrect availability causes double commitment. | High / High           | Stock movement evidence and availability rules; [Q-02](#55-Clarification-questions) |
| R-02 | Unclear expiry leaves stock reserved too long.   | Medium / Medium       | Confirm reservation policy; [Q-01](#55-Clarification-questions)                     |
| R-03 | Unique items are merged incorrectly.             | Medium / High         | Define item identification; [Q-02](#55-Clarification-questions)                     |
| R-04 | Partial order decisions are disputed.            | Medium / High         | Record line-level decision and approval; [Q-03](#55-Clarification-questions)        |
| R-05 | Commission change is made without approval.      | Medium / High         | Preserve proposed and approved terms; [Q-04](#55-Clarification-questions)           |
| R-06 | Maker reconciliation omits refund or discount.   | Medium / High         | Transaction adjustments and review; [Q-06](#55-Clarification-questions)             |
| R-07 | Volunteer sees restricted maker payments.        | Medium / High         | Permissions and authorisation tests; [Q-07](#55-Clarification-questions)            |
| R-08 | Offline records conflict when uploaded.          | High / Medium         | Event reconciliation process; [Q-08](#55-Clarification-questions)                   |

### 5.5 Clarification questions

| ID   | Question                                                                                                                                      | Ask                               | Affects                                                              |
|------|-----------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|----------------------------------------------------------------------|
| Q-01 | How long do unpaid and deposited reservations last, and who can extend them?                                                                  | Manager                           | [FR-05](#41-Functional-requirements), [UC-02](#61-Catalogue), [A-01/A-02](#52-Proposed-assumptions) |
| Q-02 | Which products require individual item IDs rather than shared quantities?                                                                     | Manager, Maker                    | [FR-01, FR-04](#41-Functional-requirements) , [A-03](#52-Proposed-assumptions)                        |
| Q-03 | Who approves substitutions, partial collection and cancellation, and how is approval evidenced?                                               | Manager, Customer representatives | [FR-07](#41-Functional-requirements), [UC-04](#61-Catalogue), [A-04](#52-Proposed-assumptions)                                    |
| Q-04 | Which commission changes require customer and maker approval?                                                                                 | Manager, Maker                    | [FR-08](#41-Functional-requirements), [UC-05](#61-Catalogue), [A-05](#52-Proposed-assumptions)                       |
| Q-05 | What return, exchange, repair and refund rules apply to standard, damaged and personalised items?                                             | Manager, legal adviser            | [FR-09](#41-Functional-requirements),[UC-06](#61-Catalogue), [A-06](#52-Proposed-assumptions)                                     |
| Q-06 | How are cooperative fees, deposits, discounts and refunds calculated and allocated to makers?                                                 | Manager, finance support          | [FR-10](#41-Functional-requirements), [A-02](#52-Proposed-assumptions)                                                            |
| Q-07 | What can each role see or change, and should Makers have access to maintain only their own product records?                                   | Manager, Makers                   | [FR-01, FR-11](#41-Functional-requirements), [NFR-01](#42-Measurable-non-functional-requirements), [A-07/A-09](#52-Proposed-assumptions)                               |
| Q-08 | What should staff do when the internet is unavailable at markets, and how should transactions be checked and errors resolved when it returns? | Market Coordinator, Manager       | [NFR-05](#42-Measurable-non-functional-requirements), [A-08](#52-Proposed-assumptions)                                                           |

## 6. Use-case Model

The use-case diagram is provided in a separate PlantUML file: ``diagrams/use-case-model.puml``.

### 6.1 Catalogue

| ID    | Actor goal / use case                            | Primary actor                                                      | Related FR          |
|-------|--------------------------------------------------|--------------------------------------------------------------------|---------------------|
| UC-01 | Process Customer Sale                            | Shop Volunteer; Market Coordinator when processing an event sale   | [FR-04, FR-10](#41-Functional-requirements)        |
| UC-02 | Manage Reservation                               | Shop Volunteer                                                     | [FR-04, FR-05](#41-Functional-requirements)       |
| UC-03 | Record Stock Movement                            | Market Coordinator                                                 | [FR-02, FR-03](#41-Functional-requirements)        |
| UC-04 | Manage Customer Order                            | Shop Volunteer                                                     | [FR-06, FR-07](#41-Functional-requirements)        |
| UC-05 | Evaluate Commission Change                       | Maker and Manager                                                  | [FR-08](#41-Functional-requirements)               |
| UC-06 | Register Return Request                          | Shop Volunteer                                                     | [FR-09](#41-Functional-requirements)               |
| UC-07 | Review Marketplace Operations and Maker Evidence | Manager                                                            | [FR-10, FR-11, FR-12](#41-Functional-requirements) |
| UC-08 | Maintain Own Product Records                     | Maker (proposed access assumption A-09)                            | [FR-01](#41-Functional-requirements)               |
| UC-09 | Review Return Case                               | Manager                                                            | [FR-09](#41-Functional-requirements)               |

### 6.2 Detailed use case: UC-02 Manage Reservation
| Field                      | Value                                                                                                 |
|----------------------------|-------------------------------------------------------------------------------------------------------|
| **Primary actor**          | Shop Volunteer.                                                                                       |
| **Goal**                   | Record a valid hold on an identified item.                                                            |
| **Trigger**                | A customer asks the volunteer to reserve an item.                                                     |
| **Preconditions**          | Volunteer is authorised; the item has a record; availability information can be checked.              |
| **Success postconditions** | Reservation and agreed terms are recorded, and the item is no longer represented as freely available. |
| **Failure postconditions** | No new confirmed reservation exists; any unresolved availability remains flagged for follow-up.       |

**Main success flow:**

1. Customer asks the volunteer to reserve a particular item.
2. Volunteer identifies the item and requests its availability.
3. System reports that the item is available for reservation.
4. Volunteer confirms customer identity/contact and agreed reservation conditions.
5. Volunteer requests reservation recording.
6. System records the customer, item, date and agreed conditions.
7. System marks the item as reserved and confirms the recorded outcome.
8. Volunteer communicates the agreed conditions to the customer.

**A1 — Item already committed (from step 3):** System reports sold or actively reserved status. No reservation is confirmed. Volunteer informs customer and may discuss an alternative item outside this use case.

**A2 — Deposit condition (from step 4):** If a deposit has been accepted by an authorised external payment process, volunteer records evidence of the deposit and the separately agreed hold conditions. The system does **not** process the payment.

**A3 — Requested extension (from step 4):** If the customer requests a non-standard hold period, the volunteer seeks the authority required by the policy; the period is not treated as approved automatically. The policy remains Q-01.

**E1 — Uncertain availability (from step 3):** If conflicting stock records prevent confirmation, the system does not create a confirmed reservation. Staff initiate a stock check.

**E2 — Incomplete customer/condition information (from step 6):** System rejects confirmation and identifies missing required reservation details. The volunteer may correct the information and retry.

**Business rules / assumptions:** BR-04; A-01 and A-02 remain proposed.

## 7. User Stories, Acceptance Criteria and Gherkin

### 7.1 Story-to-test summary

The following table summarises the user stories, their expected value, related functional requirements and use cases, and the acceptance scenarios used to verify the expected behaviour.

| Story                                      | Value                                                                | Related FR/UC                                                                   | Acceptance focus                                                                                        | Gherkin                              |
|--------------------------------------------|----------------------------------------------------------------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|--------------------------------------|
| US-01 Reserve an item                      | Prevent conflicting commitments                                      | [FR-04/05](#41-Functional-requirements), [UC-02](#61-Catalogue)                 | Reserve an available item; reject an item that is already reserved                                      | SC-01/02/03 (`marketplace.feature`)  |
| US-02 Track partial fulfilment             | Help staff identify which items are ready for collection             | [FR-06/07](#41-Functional-requirements), [UC-04](#61-Catalogue)                 | Update one order line without changing the fulfilment status of other lines                             | SC-04    (`marketplace.feature`)     |
| US-03 Control commission changes           | Preserve agreed specifications and avoid misunderstandings           | [FR-08](#41-Functional-requirements), [UC-05](#61-Catalogue)                    | A proposed change does not replace the approved terms until it is accepted                              | SC-05 (`marketplace.feature`)        |
| US-04 Record stock movements               | Maintain accurate stock availability                                 | [FR-02/03](#41-Functional-requirements), [UC-03](#61-Catalogue)                 | Record a stock movement and update the item's recorded location and availability                        | SC-06 (`marketplace.feature`)        |
| US-05 Record customer sales                | Maintain reliable sales records for the cooperative                  | [FR-01/09](#41-Functional-requirements), [UC-01](#61-Catalogue)                 | Record a sale with the relevant items, quantities and selling prices                                    | SC-07  (`marketplace.feature`)       |
| US-06 Protect maker-payment information    | Prevent unauthorised access to confidential financial information    | [NFR-01](#42-Measurable-non-functional-requirements), [UC-07](#61-Catalogue)    | Allow a volunteer to process a sale while denying access to confidential maker-payment summaries        | SC-08 (`marketplace.feature`)        |
| US-07 Record return requests               | Ensure customer issues are documented and can be reviewed            | [FR-10](#41-Functional-requirements), [UC-06/09](#61-Catalogue)                 | Record a return request and allow the manager to review its outcome                                     | SC-09  (`marketplace.feature`)       |
| US-08 Maintain product information         | Keep product descriptions and prices accurate                        | [FR-01](#41-Functional-requirements), [UC-08](#61-Catalogue)                    | Allow a maker to update their own product information without changing another maker's records          | SC-10 (`marketplace.feature`)        |
| US-09 Record sales during internet outages | Allow market operations to continue when connectivity is unavailable | [NFR-05](#42-Measurable-non-functional-requirements), [UC-01/03](#61-Catalogue) | Record transactions using the documented offline procedure and reconcile them when connectivity returns | SC-11 (`marketplace.feature`)        |

The user stories and Gherkin scenarios are maintained in separate files under `requirements/backlog.md` and `features/marketplace.feature`, respectively.

### 7.2 Acceptance criteria and Gherkin

The user stories and Gherkin scenarios are provided in separate files:

* User stories: ``requirements/user-stories.md``
* Gherkin scenarios: ``features/marketplace.feature``

## 8. Candidate-Concept Analysis and Glossary

### 8.1 Candidate extraction and decisions

| Candidate         | Source phrase / evidence                   | Classification          | Decision                                     | Reason                                                                            |
|-------------------|--------------------------------------------|-------------------------|----------------------------------------------|-----------------------------------------------------------------------------------|
| Maker             | Independent makers supply goods            | Entity                  | Keep                                         | Distinct party with product and transaction attribution                           |
| Product           | Description, materials, price, maker       | Entity                  | Keep                                         | Describes a type/design offered for sale                                          |
| One-off piece     | Unique pieces differ from design           | Entity                  | Convert to StockItem                         | Represents a distinguishable physical instance                                    |
| Stock location    | Shop, maker, event, display                | Entity                  | Keep as Location                             | Reusable location of holdings                                                     |
| Stock movement    | Products move to markets                   | Event/transaction       | Keep                                         | Explains location changes                                                         |
| Customer          | Orders, approvals and returns              | Entity                  | Keep                                         | Identifies the party placing an order                                             |
| Order             | May contain several makers' items          | Entity                  | Keep                                         | Groups customer commitments                                                       |
| Order item        | Each part may be ready at a different time | Entity                  | Keep as OrderLine                            | Required for line-level state                                                     |
| Reservation       | Items held pending payment                 | Entity                  | Keep                                         | Separate time-bound commitment                                                    |
| Commission        | Custom specifications and dates            | Entity                  | Keep                                         | Records agreed custom work                                                        |
| Commission change | Maker proposes changed terms               | Event                   | Merge into Commission in simplified model    | Keep approval history as attributes/records pending richer model                  |
| Return/repair     | Different outcomes                         | Entity                  | Keep as ReturnCase                           | Tracks after-sales issue and outcome                                              |
| Sale record       | Maker payments need evidence               | Entity                  | Keep as Sale and SaleLine                    | Sale groups a transaction; SaleLine records each sold product and its adjustments |
| Discount          | Complicates reconciliation                 | Value/attribute         | Convert to SaleLine attribute                | Monetary adjustment rather than independent actor                                 |
| Colour            | Products may differ in colour              | Attribute               | Convert to Product/StockItem attribute       | Describes an item, not a separate business party                                  |
| Spreadsheet       | Current storage method                     | Implementation artefact | Remove                                       | Not a business concept in target domain                                           |
| Payment gateway   | Online payment excluded                    | External technology     | Remove                                       | Out of scope                                                                      |

The main modelling decision is to distinguish `Product` (type/design) from `StockItem` (physical instance). 
This supports one-off pieces while still allowing standard goods to be represented as multiple units. 
It is a **proposed modelling interpretation**, not an agreed identification policy; confirm Q-02.

### 8.2 Glossary

| Term          | Definition                                                                                                              |
|---------------|-------------------------------------------------------------------------------------------------------------------------|
| Maker         | Independent craft producer supplying goods through the cooperative                                                      |
| Product       | Described type or design of craft item, including its main description, materials and base price                        |
| StockItem     | Identifiable physical unit of a product in the proposed model, allowing distinguishable pieces to be tracked separately |
| Location      | Place where stock is currently held, such as the shop, a market, a maker's premises or a display area                   |
| StockMovement | Record of a physical item's transfer between locations                                                                  |
| Customer      | Person placing an order, requesting a reservation or contacting the cooperative about an after-sales issue              |
| CustomerOrder | Customer commitment that can contain several items                                                                      |
| OrderLine     | One product and requested quantity within an order, with its own agreed price and fulfilment status                     |
| Reservation   | Recorded temporary commitment to hold a specific StockItem for a customer                                               |
| Commission    | Record of agreed customised work, including specifications, target date, agreed price and approval status               |
| ReturnCase    | Recorded return, repair or exchange request and outcome                                                                 |
| Volunteer     | Cooperative volunteer who can process sales but must not access confidential maker-payment information                  |
| Sale          | Record of a sales transaction, including its reference, date and status                                                 |
| SaleLine      | Individual line within a sale, recording the product sold, quantity, sold price and relevant financial adjustments      |

## 9. Conceptual Domain Model

The Conceptual Domain Model is provided in the separate file ``diagrams/domain-model.puml``.
It contains **14 conceptual classes**: Maker, Product, StockItem, Location, StockMovement, Customer, CustomerOrder, OrderLine, Reservation, Commission, ReturnCase, Volunteer, Sale and SaleLine. The diagram uses **selected attributes**, not every field a future implementation might store. Attributes are limited to those needed to explain the domain concepts and core requirements. There are no methods, controllers, repositories, UI controls, database foreign keys or navigability arrows.

### 9.1 Key association rationale

- One Maker supplies zero or many Products; each Product has one Maker.
- One Product describes zero or many StockItems; each StockItem is of one Product. The instance-level approach is proposed to represent one-off pieces clearly.
- One Customer places zero or many CustomerOrders; each order belongs to one customer.
- One CustomerOrder contains one or more OrderLines; each OrderLine refers to one Product. The specific physical StockItem can be assigned later, if known.
- One StockItem is held at one current Location, while a Location holds zero or many items.
- One StockMovement refers to one StockItem and has one origin and one destination Location. A StockItem can have many movements.
- One Customer may request many Reservations; a Reservation holds one StockItem. Whether sequential historical reservations are retained is proposed; conflicting **active** reservations are not permitted under the sample acceptance criteria.
- A Commission is linked to one OrderLine in this simplified model; not every OrderLine is commissioned.
- A ReturnCase may relate to a SaleLine; a SaleLine can have multiple after-sales cases over time in this proposed model.
- Each Sale contains one or more SaleLines; each SaleLine refers to one Product and is processed by one Volunteer. A Sale may be associated with a Customer if the sale is linked to a known customer; anonymous walk-in sales should be allowed if that matches the cooperative's process.
- A SaleLine may fulfil part of an OrderLine, and one OrderLine may be fulfilled through multiple SaleLines. A SaleLine may be linked to zero or one OrderLine for walk-in sales.
- A ReturnCase relates to a SaleLine. The exact deposit/refund evidence and accounting treatment remain Q-06.

### 9.4 Decision Log

| ID   | Decision                                                                                                             | Evidence / rationale                                                                                                                                        | Status                                                               |
|------|----------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| D-01 | Separate Product design from physical StockItem                                                                      | One-off pieces can differ in finish; individual stock movements must be tracked                                                                             | Proposed; confirm item-identification policy through Q-02            |
| D-02 | Keep fulfilment status on each OrderLine                                                                             | Orders involving multiple makers can be partially fulfilled                                                                                                 | Supported modelling choice                                           |
| D-03 | Allow Makers to maintain their own product records through restricted internal access                                | Makers provide product descriptions, materials, dimensions, prices, photographs and care information; direct system access is not confirmed in the scenario | Proposed assumption A-09; confirm through Q-07                       |
| D-04 | Record proposed commission changes separately from approved terms                                                    | Messages can create uncertainty about agreed specifications, prices and completion dates                                                                    | Proposed; confirm approval rules through Q-04                        |
| D-05 | Do not hard-code a universal three-day reservation expiry                                                            | The scenario does not specify an approved reservation duration                                                                                              | Open; Q-01                                                           |
| D-06 | Restrict Makers to their own product records and keep confidential maker-payment summaries unavailable to Volunteers | Supports product-data responsibility while preserving the stated volunteer privacy constraint                                                               | Proposed; confirm role permissions through Q-07                      |
| D-07 | Separate Sale from SaleLine                                                                                          | A sale can contain multiple sold items; each line needs its own price and financial adjustments                                                             | Proposed modelling choice; confirm transaction evidence through Q-06 |

## 10. Traceability Matrix

The traceability matrix is provided in the separate file `requirements/traceability.csv`.