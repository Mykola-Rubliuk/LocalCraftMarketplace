# Open questions and risks requiring group/stakeholder clarification

| ID | Question | Impacted artefacts |
|---|---|---|
| Q-01 | What is the approved reservation expiry policy, including deposits, weekends and public holidays? | Slice 1, ReservationPolicy, Clock |
| Q-02 | Does each itemCode identify one physical unit, or can it represent quantity/batches? | Shared stock port, Slice 4, Slice 3 |
| Q-03 | What evidence is sufficient to record customer approval for substitution/cancellation? | Slice 2 |
| Q-06 | What sale adjustments (discount/deposit/refund) are required in the sale record? | Slice 4, maker evidence |
| Q-07 | What exact roles may view maker payment data and maintain product records? | Security and scope |
| Q-08/Q-09 | Who captures, reconciles and resolves offline conflicts, and how are duplicate references identified? | Slice 3 |
| Q-SH-01 | Can a reserved item be sold to the customer holding that reservation? | Shared stock port and Slice 4 |
| Q-SH-02 | Is reconciliation idempotent if a user retries after a timeout? | Slice 3 / Slice 4 |
| Q-SH-03 | Which working-day calendar does Clock use? | Slice 1 |
| Q-SH-04 | What does quantity mean when stock is represented by individual item codes? | Slice 4 |
