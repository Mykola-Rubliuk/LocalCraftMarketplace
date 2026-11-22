# CA2 — Collaborative Object-Oriented Design
**Scenario:** Local Craft Marketplace — Kerry Makers Cooperative  

## Product Goal
Help authorised cooperative staff coordinate craft-item availability, reservations, multi-maker order fulfilment and sales, while preserving maker attribution and transaction evidence, including a controlled process for offline market transactions.

## Current design slices
| Slice | Use case | Main operation | Primary responsibility |
|---|---|---|---|
| 1 | UC-02 Reserve an item | `recordReservation` | ReservationService |
| 2 | UC-04 Fulfil order lines | `recordCollection` (plus line decisions) | OrderFulfilmentService |
| 3 | UC-10 Reconcile offline transactions | `reconcile` | OfflineReconciliationService |
| 4 | UC-01 Process a customer sale | `recordSale` | SaleService |

## Repository map
- `docs/` — scenario baseline, Product Goal, scope, design dossier and glossary.
- `backlog/` — CA2 work backlog and traceability.
- `slices/slice-1` … `slice-4/` — use case, Gherkin, SSD, contracts, CRC, GRASP and design sequence.
- `design/` — integrated design class model, package/layer view and shared interface catalogue.
- `decisions/` — decision log and open questions.
- `reviews/` — review templates; complete these after actual review.
- `ai/` — group declaration and interaction log template.
- `submission/` — final checklist and contribution statement template.
