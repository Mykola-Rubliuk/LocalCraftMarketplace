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

The slice proposals were supplied by the group conversation and are treated as the current working allocation. Member names/ownership must be confirmed in the board. Slice 4 is currently assigned to the repository owner who supplied the project link; confirm this mapping with the group.

## Repository map
- `docs/` — scenario baseline, Product Goal, scope, design dossier and glossary.
- `backlog/` — CA2 work backlog and traceability.
- `slices/slice-1` … `slice-4/` — use case, Gherkin, SSD, contracts, CRC, GRASP and design sequence.
- `design/` — integrated design class model, package/layer view and shared interface catalogue.
- `decisions/` — decision log and open questions.
- `reviews/` — review templates; complete these after actual review.
- `ai/` — group declaration and interaction log template.
- `submission/` — final checklist and contribution statement template.

## How to use
1. Import this folder into the team's GitHub repository or merge its contents into the existing `part 2` branch.
2. Agree the scenario and baseline; confirm whether UC-10 and its FR/SC identifiers are accepted CA2 baseline items.
3. Confirm the number of use cases with the lecturer. The brief's Section 7 says 1–3, while the marking rubric refers to 3–5. The four proposed slices therefore need lecturer clarification before being treated as the final assessed scope.
4. Review shared contracts before individual work is marked complete.
5. Each slice owner validates their own artefacts and opens a pull request. Another member reviews it.
6. Reconcile all diagrams/contracts and complete the dossier, AI declarations and contribution evidence.
7. Create `ca2-submission` only after the final review.

## Diagram rendering
All `.puml` files are editable PlantUML source. Render them with PlantUML (IDE plugin, local PlantUML installation, or the official online server). PNG exports are intentionally not included; generate them from the reviewed source after changes stop.
