# UC-01 — Process a Customer Sale

**Primary actor:** Shop Volunteer; Market Coordinator may also record a sale at a market event.  
**Goal:** Record a sale accurately and retain maker-attributable transaction evidence.  
**Trigger:** A customer agrees to purchase one or more items.  
**Related:** US-05; FR-01, FR-04, FR-10; BR-01; Q-06, Q-SH-01, Q-SH-02, Q-02 / Q-SH-04.

## Preconditions
- Processor is authorised to record sales.
- The request has an idempotency key and at least one sale line.
- Each item code resolves through ProductCatalogue and has maker attribution.
- Quantity, sold price and any discount satisfy the agreed validation rules.
- Each item is Available through the shared StockAvailabilityPort.
- An offline caller supplies the actual sale date from the offline form.

## Main success flow
1. Processor submits a `SaleRequest` through `SaleRecordingPort`.
2. `SaleService` validates the request, processor and idempotency key.
3. `ProductCatalogue` resolves every item and its maker attribution.
4. `SaleService` validates quantity, sold price and any discount.
5. `SaleService` checks every item through `StockAvailabilityPort.getStatus(itemCode)`.
6. If all lines pass, `SaleService` creates the Sale and SaleLine data.
7. The provider performs the all-or-nothing stock transition through `sellAllIfAvailable(itemCodes, idempotencyKey)` and persists the sale consistently.
8. The provider stores the idempotency result and returns `Recorded(saleRef)`.

## Alternative / refusal flows
- A1 — Empty line list: `Rejected(NoLines)`.
- A2 — Unauthorised processor: `Rejected(UnauthorisedProcessor)`.
- A3 — Invalid price, quantity or discount: `Rejected(InvalidPrice / InvalidQuantity / InvalidDiscount)`.
- A4 — Unknown item: `Rejected(ItemNotFound)`.
- A5 — Any item is Reserved or Sold: `Rejected(ItemUnavailable)`. A reserved item is not sellable until Q-SH-01 is resolved and the shared contract is explicitly changed.
- A6 — Missing maker attribution: `Rejected(MissingMakerAttribution)`.
- A7 — Same idempotency key and same payload: return the original result; do not create another Sale.
- A8 — Same idempotency key with a different payload: `Rejected(IdempotencyKeyConflict)`.
- A9 — One of several lines fails: reject the whole request; no line is sold.
- A10 — Technical failure in stock or persistence: report a technical failure; no partial sale or stock changes may remain.

## Postconditions
**Success:** one Completed Sale exists; every SaleLine retains product and maker evidence; stock items are Sold; the result contains `saleRef`.  
**Business refusal:** no Sale/SaleLine is created and stock is unchanged; the result is `Rejected(reason)`.  
**Technical failure:** no partial sale/stock changes remain; caller must not assume success.
