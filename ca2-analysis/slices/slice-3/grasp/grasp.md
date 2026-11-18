# GRASP justification — Slice 3

| Decision | Pattern | Justification | Alternative rejected |
|---|---|---|---|
| OfflineReconciliationService receives enterOfflineTransaction, reconcile and resolve | Controller | One use-case controller for UC-10 coordinates the system operations from the SSD (D-CA2-01) | UI or OfflineTransaction handling the operations — mixes presentation or entity state with coordination |
| OfflineReconciliationService creates OfflineTransaction and OfflineLines | Creator | It holds the initialising data from the form and records the transaction | Repository creating objects — repository should only store and find |
| OfflineTransaction changes its own status (markReconciled, refer, resolve) | Information Expert | It knows its current status and which transitions are allowed | Service setting the status field directly — transition rules would be spread across the service |
| ConflictChecker checks duplicates and item conflicts | Pure Fabrication, High Cohesion | All checking rules in one place, testable without the service; no domain concept owns both reference and stock checks | Putting the checks in the service — makes the controller bloated; in OfflineTransaction — the entity would depend on stock and repository |
| StockAvailabilityPort and SaleRecordingPort used through interfaces | Protected Variations, Indirection | Slice 3 is protected from changes in stock and sale implementations; fakes stand in before integration (D-CA2-03, D-CA2-04, D-CA2-08) | Slice 3 creating Sale objects or updating stock directly — two paths for sale recording, double stock updates |
| Slice 3 does not create Sale/SaleLine or change stock | Low Coupling | Only SaleRecordingPort records sales and marks items sold (K1) | Slice 3 posting sales itself |
| Clock injected | Protected Variations | Dates and "not in the future" checks are testable with a fixed clock | Calling the system clock directly |
| OfflineTransactionRepository as a port | Indirection, Pure Fabrication | Storage can be in-memory for tests and real later | Static list inside the service |