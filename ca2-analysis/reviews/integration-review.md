# Integration review checklist

- [ ] One shared glossary and consistent identifiers.
- [ ] All selected slices use the same shared port semantics.
- [ ] Slice 4 is the only provider of SaleRecordingPort.
- [ ] Slice 3 calls SaleRecordingPort rather than constructing a sale itself.
- [ ] Slice 1 expiry policy is not hard-coded as an approved duration.
- [ ] Slice 2 order status is derived consistently from line states.
- [ ] Sale atomicity is credible across sale persistence and stock updates.
- [ ] Quantity/itemCode semantics are resolved.
- [ ] Reserved-item sale policy is resolved.
- [ ] One integrated class diagram contains all participating classes and interfaces.
- [ ] All sequence messages map to operations in the design class model.
- [ ] Traceability matrix has no broken or missing links.
- [ ] Review records are genuine and linked to PRs.
