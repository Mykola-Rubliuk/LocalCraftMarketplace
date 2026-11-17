# Slice 4 — Operation contract

## OC-4.1 `recordSale(processedBy, customerRef?, lines)`

**Preconditions**
- `processedBy` identifies an authorised processor.
- `lines` contains at least one line.
- Every item code resolves through ProductCatalogue.
- Every item has maker attribution.
- Each price and quantity is valid and non-negative.
- Every item is Available, or meets a separately approved reservation-holder rule.
- The sale request is not a duplicate if idempotency is supported.

**Postconditions on success**
- One Sale is created with a unique saleRef and status Completed.
- One SaleLine is created per requested line.
- Each SaleLine links to the relevant Product/StockItem and Maker attribution.
- Each SaleLine stores soldPrice, quantity and discountAmount.
- Each stock item is marked Sold through StockAvailabilityPort.
- Sale and stock changes are committed atomically.

**Failure guarantee**
- No Sale or SaleLine is created.
- No stock item is marked Sold.
- Result identifies `NoLines`, `InvalidPrice`, `InvalidQuantity`, `ItemNotFound`, `ItemUnavailable`, `MissingMakerAttribution` or `UnauthorisedProcessor`.
