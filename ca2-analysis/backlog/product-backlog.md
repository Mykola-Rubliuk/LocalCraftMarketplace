# CA2 Product Backlog


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

## Board workflow
Backlog → Ready → In Progress → Peer Review → Done. Use Blocked when a decision/dependency prevents progress.
