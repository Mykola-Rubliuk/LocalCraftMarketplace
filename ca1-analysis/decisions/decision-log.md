# Decision log

| ID | Decision | Evidence / rationale | Status |
|---|---|---|---|
| D-01 | Separate Product design from physical StockItem | One-off pieces can differ in finish; individual stock movements must be tracked | Proposed; confirm item-identification policy through Q-02 |
| D-02 | Keep fulfilment status on each OrderLine | Orders involving multiple makers can be partially fulfilled | Supported modelling choice |
| D-03 | Allow Makers to maintain only their own product records through restricted internal access | Makers provide descriptions, materials, dimensions, prices and care information; direct system access is not confirmed in the scenario | Proposed assumption A-09; confirm through Q-07 |
| D-04 | Record proposed commission changes separately from approved terms | Separate messages create uncertainty about agreed specifications, prices and dates | Proposed; confirm approval rules through Q-04 |
| D-05 | Do not hard-code a universal three-day reservation expiry | The scenario does not specify an approved reservation duration | Open; Q-01 |
| D-06 | Keep confidential maker-payment summaries unavailable to Volunteers | Preserves the stated volunteer privacy constraint (BR-04) | Proposed; confirm role permissions through Q-07 |
| D-07 | Separate Sale from SaleLine | A sale can contain several items; each line needs its own price and financial adjustments | Proposed modelling choice; confirm transaction evidence through Q-06 |
| D-08 | Keep Customer as an offstage stakeholder initially | No confirmed direct customer access to the system | Proposed; Q-07 |
| D-09 | Record return requests separately from the Manager's decision on their outcome | Return, exchange and repair practices vary and the approval policy is unresolved | Proposed; Q-05 |
| D-10 | Capture offline sales by an approved manual procedure and reconcile them in the system (FR-13, UC-10) | Internet access at markets may be unreliable; NFR-05 needs later reconciliation without unaccounted transactions | Proposed; confirm through Q-08, Q-09 |
| D-11 | Represent each offline sale as an OfflineTransaction with a reconciliation status | Keeps unreconciled records separate from confirmed Sales and makes duplicates and conflicts visible | Proposed; Q-08 |
| D-12 | Do not take new reservations, orders or commission changes while offline (A-10) | Avoids double commitment while the system is unavailable | Proposed; Q-09 |
