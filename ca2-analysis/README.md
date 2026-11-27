# CA2 — Collaborative Object-Oriented Design
**Scenario:** Local Craft Marketplace — Kerry Makers Cooperative  

## Product Goal
Help authorised cooperative staff coordinate craft-item availability, reservations, multi-maker order fulfilment and sales, while preserving maker attribution and transaction evidence, including a controlled process for offline market transactions.

## Current design slices
| Slice | Use case | Main operation | Primary responsibility |
|---|---|---|---|
| 1 | UC-02 Manage Reservation | `recordReservation` | ReservationService |
| 2 | UC-04 Manage Customer Order | `recordCollection` (plus line decisions) | OrderFulfilmentService |
| 3 | UC-10 Reconcile offline transactions | `reconcile` | OfflineReconciliationService |
| 4 | UC-01 Process a customer sale | `recordSale` | SaleService |

Use-case names above follow the CA1 catalogue exactly (`ca1-analysis/report/analysis_dossier.md`, §6.1); slice folders and the backlog use the same names (D-CA2-19).

## Repository map
- `docs/` — scenario baseline, Product Goal, scope, design dossier and glossary.
- `backlog/` — CA2 work backlog and traceability.
- `ca1-reference/` — copy of the CA1 README kept for cross-reference.
- `project-management/` — definition of done and iteration plan.
- `slices/slice-1` … `slice-4/` — use case, Gherkin, SSD, contracts, CRC, GRASP and design sequence.
- `design/` — integrated design class model and shared interface/error catalogues. The package/layer view (PB-08) is still in Backlog status and is not in this folder yet.
- `decisions/` — decision log and open questions.