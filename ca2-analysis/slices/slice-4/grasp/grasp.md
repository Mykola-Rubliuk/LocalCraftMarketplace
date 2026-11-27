# Slice 4 — GRASP decisions

1. **Controller — SaleService.** It receives the `recordSale` system event and coordinates the sale workflow. Alternative: make Sale itself coordinate catalogue and stock services. Rejected because the entity would become coupled to external collaborators.
2. **Information Expert — SaleLine.** It owns price, quantity and discount values and can calculate its line amount. Alternative: keep all line arithmetic in SaleService. Rejected because the data and calculation would be separated.
3. **Information Expert — Sale.** It owns the collection of SaleLines and calculates the sale total from them.
4. **Pure Fabrication — SaleRepository.** Persistence is not a natural responsibility of Sale; repository keeps storage concerns outside the domain entity.
5. **Indirection / Protected Variations — StockAvailabilityPort and SaleRecordingPort.** They isolate shared stock semantics and provide Slice 3 with a stable sale-recording capability.
6. **High Cohesion / Low Coupling — ProductCatalogue.** Product/maker lookup is isolated from sale orchestration; SaleService does not know how product records are stored.
7. **Atomicity as an invariant.** The sale coordinator must ensure no partial sale or stock mutation survives a failed line. A simple sequence of independent writes is insufficient; the implementation design needs a unit-of-work/transaction boundary or explicit compensation.
8. **Indirection — CurrentUser (D-CA2-20).** It sits between SaleService and however sign-in works, providing the signed-in user's ID so SaleService can compare it with `processedBy` for a new in-store sale. Alternative: accept the caller-supplied `processedBy` without comparing it. Rejected because an in-store sale could then be recorded under another authorised user's ID.
