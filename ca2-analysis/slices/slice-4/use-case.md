# UC-01 — Process a customer sale

**Primary actor:** Shop Volunteer (also Market Coordinator at an event).  
**Goal:** Record a sale accurately and retain maker-attributable transaction evidence.  
**Trigger:** Customer agrees to purchase one or more items.  
**Related:** US-05; FR-01, FR-04, FR-10; BR-01; Q-06; SC-07.

## Preconditions
- Processor is authorised to record sales.
- At least one sale line is supplied.
- Each item code identifies a valid sellable stock unit or quantity model agreed by the group.
- Prices and discounts are valid and non-negative.
- Each item is eligible for sale under the shared stock policy.

## Main success flow
1. Processor submits customer reference (optional), processor identity and sale lines.
2. SaleService validates processor authorisation and that at least one line exists.
3. ProductCatalogue resolves each item and its maker attribution.
4. SaleService validates prices, quantities and discounts.
5. SaleService checks availability for every item through StockAvailabilityPort.
6. If every line passes, SaleService creates Sale and SaleLine records with maker attribution and monetary adjustments.
7. SaleService marks each item Sold and persists the sale atomically.
8. System returns SaleRecorded with sale reference.

## Alternative / refusal flows
- A1 — Empty line list: reject with `NoLines`.
- A2 — Negative/invalid price, quantity or discount: reject with `InvalidPrice` / `InvalidQuantity` / `InvalidDiscount`.
- A3 — Unknown item: reject with `ItemNotFound`.
- A4 — Any item Reserved or Sold: reject with `ItemUnavailable` unless an approved reservation-holder rule applies.
- A5 — One of several lines fails: reject the entire sale; no Sale/SaleLine is created and no item is marked Sold.
- A6 — Missing maker attribution: reject or refer for correction; never record a sale line without maker evidence.
- A7 — Duplicate request retry: return the original sale result if idempotency key is supported; otherwise this is an unresolved risk and must not be guessed.

## Postconditions
**Success:** one Completed Sale exists; all SaleLines are linked to Product and Maker evidence; discounts are recorded at line level; all items are Sold.  
**Failure:** no Sale or SaleLine exists; no stock status changes.

## Unresolved
Confirm whether itemCode identifies one unit or a quantity batch, the reservation-holder exception, discount constraints, deposits/refunds and idempotency key strategy.
