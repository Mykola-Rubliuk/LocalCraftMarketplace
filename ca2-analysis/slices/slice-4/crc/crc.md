# Slice 4 — CRC cards

## SaleService
**Responsibilities:** receive sale request; validate processor and lines; resolve product/maker details; check availability; coordinate atomic creation of sale and sale lines; update stock; return explicit result; implement SaleRecordingPort.  
**Collaborators:** Sale, SaleLine, SaleRepository, StockAvailabilityPort, ProductCatalogue, Clock.

## Sale
**Responsibilities:** know saleRef, processor, customer reference, date and status; contain sale lines; calculate/validate total from line values.  
**Collaborators:** SaleLine, SaleService.

## SaleLine
**Responsibilities:** know item/product, maker attribution, sold price, quantity and discount amount; calculate line net amount under agreed rules.  
**Collaborators:** Sale, Product, Maker.

## ProductCatalogue
**Responsibilities:** find item/product and maker attribution by itemCode; return a not-found or incomplete-attribution result.  
**Collaborators:** SaleService, Product, Maker.

## SaleRepository
**Responsibilities:** persist and retrieve Sale aggregate; support atomic save/idempotency if agreed.  
**Collaborators:** SaleService.

## StockAvailabilityPort
**Responsibilities:** shared availability query and stock state transitions.  
**Collaborators:** SaleService and other slices.
