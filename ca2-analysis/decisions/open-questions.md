# Open Questions and Risks Requiring Group / Stakeholder Clarification

| ID | Question | Impacted artefacts |
|---|---|---|
| Q-01 | What is the approved reservation expiry policy, including deposits, weekends and public holidays? | Slice 1, ReservationPolicy, scenario tests |
| Q-02 | Does each `itemCode` identify one physical unit, or can it represent multiple units / a batch? | Shared stock port, Slice 3 and Slice 4 sale lines |
| Q-03 | What evidence is sufficient to record customer approval for substitution/cancellation? | Slice 2 |
| Q-06 | Which sale adjustments (discounts, deposits, refunds and corrections) must be retained, and what validation rules apply? | Slice 4, maker transaction evidence |
| Q-07 | What exact roles may view maker payment data and maintain product records? | Security and product-management scope |
| Q-08 / Q-09 | Who captures, reconciles and resolves offline conflicts, and how are duplicate references identified? | Slice 3, offline process |
| Q-SH-01 | Can an item be sold to the customer who currently holds its reservation? Until agreed, Reserved items are not sellable. | StockAvailabilityPort, Slice 4 |
| Q-SH-02 | Is the proposed idempotency behaviour approved for retries after a timeout, and what key/payload rules must apply? | Slice 3 / Slice 4, SaleRecordingPort |
| Q-SH-03 | Which working-day calendar and date-boundary rule does ReservationPolicy use? | Slice 1, reservation expiry |
| Q-SH-04 | What does `quantity` mean when stock is represented by individual item codes? | Slice 3 / Slice 4 sale lines, stock port |
| Q-SH-05 | Should `reconcile` and `resolve` select a record by unique `entryId` or by potentially repeated `offlineRef`? | Slice 3 operation contracts and UI |
| Q-SH-06 | Does the group approve the proposed SaleRequest fields needed by offline reconciliation: past `saleDate`, offline `soldPrice`, `sourceRef` and `idempotencyKey`? | SaleRecordingPort, Slice 3 / Slice 4 |
| Q-SH-07 | Does any active reservation make an offline sale a conflict? Current Slice 3 proposal treats Reserved as a conflict. | Slice 3 conflict checker, stock policy |
| Q-SH-08 | Is UC-10 confirmed as in CA2 scope? | Slice 3, PB-01, scenario selection |
| Q-SH-10     | What is the agreed name of UC-04: 'Fulfil order lines' or 'Manage Customer Order'? Until agreed, UC-04 name is "Fulfil Order Lines".                               | Slice 2, README, PB-05, US-02, AD-02, scenario selection |
| Q-SH-11     | Which use case records a customer order, now that UC-04 covers only fulfilment of order lines? FR-06 asks the system to record orders, but no slice does. | Slice 2 preconditions, FR-06 traceability, baseline change log |

## Integration risks

- SaleRepository persistence and stock state changes may be separate resources. The group must agree the transaction boundary or a safe prepare/commit/compensation design before claiming cross-resource atomicity is implemented.
- Slice 3 can read stock before calling SaleRecordingPort, but stock may change between the read and the sale call. Slice 4 must re-check and perform the atomic stock transition.
- The uploaded archive does not contain `docs/agreed-baseline.md`, `docs/baseline-change-log.md` or an existing shared contract test file. These artefacts are required for a complete baseline and test review.
