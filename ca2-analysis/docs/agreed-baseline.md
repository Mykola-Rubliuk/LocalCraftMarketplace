# Agreed CA1 Baseline — CA2 reference restatement

This document restates the CA1 analysis elements retained for the selected CA2 scenario. It does not replace the CA1 analysis, invent stakeholder approvals, or change the status of design decisions. The selection and scope are recorded in [scenario-selection.md](scenario-selection.md) and [baseline-change-log.md](baseline-change-log.md). This restatement was prepared from those records, the CA1 dossier and the available CA2 slice evidence.

## 1. Scenario, goal and boundary

Local Craft Marketplace — Kerry Makers Cooperative is the selected scenario. CA2 retains the goal of reliable item availability, reservations, order progress, sale evidence and controlled offline reconciliation, as described in [product-goal.md](product-goal.md).

The authorised Shop Volunteer, Market Coordinator and Manager are the direct operational actors for the selected use cases. Customers remain offstage; the Maker is a stakeholder whose product and transaction attribution matters. CA1's possible direct Maker access to product records remains an assumption (A-09), not a newly approved feature.

Public e-commerce, online payments and full accounting remain excluded (BR-05). CA2 does not design automatic offline synchronisation; forms are completed manually outside the system and entered after connectivity returns. Other CA1 use cases remain contextual requirements outside the principal four-slice design scope.

## 2. Retained use cases and trace links

| Slice | CA1 canonical use case | Story | Requirements | Rules/assumptions | Scenarios | Core concepts |
|---|---|---|---|---|---|---|
| 1 | UC-02 Manage Reservation | US-01 | FR-04, FR-05 | A-01, A-02 | SC-01–03 | StockItem, Reservation, Customer |
| 2 | UC-04 Manage Customer Order | US-02 | FR-06 (order context), FR-07 (fulfilment) | BR-02, BR-03, A-04 | SC-04 | CustomerOrder, OrderLine, Customer, Maker |
| 3 | UC-10 Reconcile Offline Transactions | US-09; CA2 US-CA2-01 | FR-13, NFR-05 | A-08, A-10; BR-01, BR-05 | SC-11–15 | OfflineTransaction, StockItem, Sale, SaleLine |
| 4 | UC-01 Process Customer Sale | US-05 | FR-01, FR-04, FR-10 | BR-01 | SC-07 | Sale, SaleLine, Product, Maker, StockItem |

## 3. Retained requirements and rules

- FR-01: retain maker, product description and selling price; FR-04: determine availability using recorded sales and active reservations.
- FR-05: record the item, customer and agreed reservation conditions.
- FR-06: customer orders contain one or more lines; FR-07: record each line's fulfilment status independently.
- FR-10: preserve sale evidence identifying the maker and monetary adjustments.
- FR-13: record offline transactions and reconciliation status, detect duplicates and conflicts, and support authorised reconciliation and manager review.
- NFR-05: support a workable offline recording procedure and subsequent reconciliation without losing transactions.
- BR-01: attribute sold items to their makers; BR-02: orders can include multiple makers; BR-03: item-level readiness must be distinguishable; BR-05: exclude public e-commerce, payment processing and full accounting.
- BR-04 and NFR-01 remain relevant wider access-control requirements but are not a separate reservation business rule or selected CA2 use case.

Full requirement text and evidence are retained in the CA1 dossier. The descriptions above are concise indexes, not replacements.
