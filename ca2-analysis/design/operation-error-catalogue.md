## Slice 4 — Customer Sale: Error Catalogue

| Error | Meaning | Possible cause | Expected handling |
|---|---|---|---|
| `ItemNotFound` | The requested item does not exist in the product catalogue. | The supplied item code is incorrect, unknown or no longer registered. | Reject the sale. Do not create a Sale or SaleLine. Do not change stock availability. |
| `ItemUnavailable` | The requested item exists but is not available for sale. | The item is already sold, reserved, unavailable or otherwise cannot be sold. | Reject the sale. Do not create a Sale or SaleLine. Keep the item's current availability status unchanged. |
| `InvalidQuantity` | The requested quantity is invalid. | The quantity is zero, negative or does not meet the quantity rules for the item. | Reject the sale. Do not create a Sale or SaleLine. Do not change stock availability. |
| `InvalidPrice` | The supplied sale price is invalid. | The price is negative, missing or does not satisfy the agreed pricing rules. | Reject the sale. Do not create a Sale or SaleLine. Do not change stock availability. |
| `NoLines` | The sale request does not contain any sale lines. | The request contains an empty or missing lines collection. | Reject the sale before processing. Do not create a Sale or update stock. |
| `MissingMakerAttribution` | The requested item does not have an associated maker. | The product or stock item has no valid maker reference. | Reject the sale. Do not create a Sale or SaleLine until maker attribution is corrected. |
| `UnauthorisedProcessor` | The person attempting to process the sale is not authorised. | The processor is not authenticated, does not have the required role or has insufficient permissions. | Reject the request before creating the sale or changing stock. |
| `StockUpdateFailed` | The system could not update the availability status of one or more stock items. | The stock service returned an error, the update failed or the stock item could not be marked as sold. | Roll back the entire sale operation. No Sale, SaleLine or partial stock changes should remain committed. |
| `PersistenceFailed` | The system could not save the sale or one of its sale lines. | A database error, connection failure, constraint violation or other persistence error occurred. | Roll back the entire sale operation. No incomplete Sale, SaleLine or stock changes should remain committed. |

### General Failure Handling Rule

All sale-processing operations must follow an all-or-nothing approach.

If any operation fails before the sale is successfully committed:

- The sale must not be partially recorded.
- No incomplete Sale or SaleLine records should remain.
- Stock availability changes made as part of the operation must be rolled back.
- The system must return an appropriate failure result identifying the error.
- The original stock availability must be preserved.
