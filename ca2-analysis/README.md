# CA2 — Collaborative Object-Oriented Design

**Scenario:** Local Craft Marketplace — Kerry Makers Cooperative

## Product Goal

Help authorised cooperative staff coordinate craft-item availability, reservations, multi-maker order fulfilment and sales, while preserving maker attribution and transaction evidence, including the reconciliation of offline market transactions.

## Design Slices

| Slice | Use Case | Main Operation | Controller |
|---|---|---|---|
| 1 | UC-02 Manage Reservation | `recordReservation` | ReservationService |
| 2 | UC-04 Manage Customer Order | `recordCollection` and line decisions | OrderFulfilmentService |
| 3 | UC-10 Reconcile Offline Transactions | `reconcile` | OfflineReconciliationService |
| 4 | UC-01 Process Customer Sale | `recordSale` | SaleService |

## Repository Structure

- `docs/` — scenario baseline, Product Goal, scope, design dossier and glossary.
- `backlog/` — Product Backlog and traceability matrix.
- `ca1-reference/` — CA1 reference documentation.
- `project-management/` — Definition of Done and iteration plan.
- `slices/` — individual use cases, Gherkin scenarios, SSDs, operation contracts, CRC cards, GRASP decisions and sequence diagrams.
- `design/` — integrated design class diagram, package/layer view and shared interface and error catalogues.
- `decisions/` — decision log and open questions.