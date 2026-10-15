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

| ID | Scenario evidence | Business problem | Potential consequence |
|---|---|---|---|
| P-01 | Quantities and locations are not consistently updated, 'available' may not mean available in shop | Unreliable availability information | Staff promise an item that cannot be supplied |
| P-02 | One-off pieces may differ from a standard design; staff disagree about individual records | Ambiguous item identification | Unique pieces may be confused or counted twice |
| P-03 | Reservations vary; some are pending payment or deposit | Inconsistent reservation control | Unclear stock commitments and missed sales |
| P-04 | Mixed-maker orders may be partly ready; customer decisions are not consistently recorded | Incomplete order-level and item-level status | Customer and staff disagree about fulfilment |
| P-05 | Commission changes and approvals appear in separate messages | Weak change history | Disputes about agreed materials, price or date |
| P-06 | Returns, repairs and exchanges have inconsistent recording | Missing after-sales history | Unclear outcome and difficult follow-up |
| P-07 | Discounts, deposits and refunds complicate maker reconciliation | Incomplete transaction evidence | Amounts attributable to makers may be wrong |
| P-08 | Volunteers should not see all maker-payment details, markets have unreliable internet | Access and connectivity constraints | Privacy exposure or delayed records |

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

| ID | Stakeholder | Classification | Goal | Concern | Influence |
|---|---|---|---|---|---|
| ST-01 | Cooperative Manager | Direct | Trustworthy stock, orders, commissions and maker summaries | Inaccurate reconciliation, unresolved cases | High: approves policies and priorities |
| ST-02 | Shop Volunteer | Direct | Sell and reserve items accurately | Unclear availability; excessive financial access | Medium: daily process knowledge |
| ST-03 | Market Coordinator | Direct | Transfer and sell event stock with correct records | Connectivity and stale shop stock | Medium: event process knowledge |
| ST-04 | Maker | External stakeholder; proposed internal-system user for own product records | Maintain accurate product details; correct attribution and fair payment evidence | Unique pieces, commission changes, payment errors | High: product and commission rules |
| ST-05 | Customer | External | Know item readiness and agreed terms | Delays, substitutions, return outcomes | Medium: service expectations |
| ST-06 | Accounting / payment support | Indirect, conditional | Reliable evidence for reconciliation | Missing discounts, refunds or deposits | Medium if role exists; confirm Q-06 |

### 3.2 Actors and goals

| Actor | Type | Goal | Use cases |
|---|---|---|---|
| Shop Volunteer | Primary | Record a sale and order decisions; reserve items; open a return case | UC-01, UC-02, UC-04, UC-06 |
| Market Coordinator | Primary | Record stock transfers and event transactions | UC-03, UC-01 |
| Manager | Primary | Coordinate commission decisions; review marketplace operations, maker evidence and return cases | UC-05, UC-07, UC-09 |
| Maker | Proposed primary actor (assumption A-09) | Maintain own product records and provide input on commission feasibility | UC-05, UC-08 |
| Customer | Offstage stakeholder | Request items and approve changes | Indirectly influences UC-02/UC-04/UC-05 |

Actor assignments are proposed. 
Maker access is an explicit project assumption (A-09), not a confirmed scenario fact.
Customer remains offstage and has no direct system access in this scope.
