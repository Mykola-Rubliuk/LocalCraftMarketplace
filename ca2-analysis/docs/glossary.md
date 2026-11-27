# Shared Glossary

Use these terms consistently across all slices and shared contracts.

| Term | Meaning |
|---|---|
| Product | A craft design or product type, including its description, maker and base selling price. |
| Stock item | A physical item or stock unit tracked for availability. |
| `itemCode` | Stable identifier used to look up a stock item through `StockAvailabilityPort`. CA1 assumption A-03 proposes a distinct ID for each one-off piece, while interchangeable standard stock may share a product type. The exact stock-unit / quantity mapping remains open under Q-02 / Q-SH-04. |
| Stock status | One of `Available`, `Reserved`, `Sold` or `Unknown`, returned by the shared stock contract. |
| Reservation | A recorded commitment of an item to a customer under agreed conditions and an agreed expiry date. |
| Active reservation | A reservation whose status is `Active` and whose agreed expiry has not been reached. |
| Customer order | A customer's request containing one or more order lines. |
| Order line | One item commitment within an order, with its own fulfilment status. |
| Sale | A completed transaction record containing one or more sale lines. |
| Sale line | Item-level sale evidence including item code, quantity, sold price, applicable discount and maker attribution. |
| Offline transaction | A sale captured on an offline form and entered into the system for later reconciliation. |
| Offline reference (`offlineRef`) | Reference written on the offline form. It may be repeated and is not the internal record identifier. |
| Submission ID (`submissionId`) | Client-generated key used to prevent the same offline form entry from being stored twice after a retry. |
| Entry ID (`entryId`) | Unique internal identifier assigned to an `OfflineTransaction`. It is used to select and reconcile a particular stored entry. |
| Reconciliation | Validation and controlled recording of an offline transaction as a Sale. |
| Port | An interface boundary through which a service uses a capability without depending on its implementation. |
| Fake | A simple in-memory implementation of a port or repository used for tests. |
| Idempotency key | Stable request identifier. Repeating the same request with the same key must not create a second result or transaction. |
| Atomic operation | An operation in which all requested changes succeed together or none remain committed. |
| Expected refusal | A business outcome returned as a result variant, such as `Rejected(reason)`. |
| Technical failure | An infrastructure or processing failure, such as a database or unavailable service. It is not treated as a normal business refusal. |
| `saleDate` | Date the customer actually made the purchase. For offline sales, this is the date written on the offline form. |
| `recordedAt` | Date and time the system recorded the transaction, supplied by `Clock`. |
| `sourceRef` | Optional external reference for the source record, such as an `offlineRef`. |

## Shared naming rules

- Use `getStatus(itemCode)` for stock lookups in every slice.
- Use the stock status values `Available`, `Reserved`, `Sold` and `Unknown`.
- Use `SaleRecordingResult` with `Recorded(saleRef)` and `Rejected(reason)` for the sale port.
- Use `saleRef` consistently for the identifier returned by sale recording.
- Use `entryId` to select a stored offline transaction. Keep `offlineRef` as its external business reference.
- Use `idempotencyKey` for a sale-recording request and `submissionId` for an offline-entry submission.
- Expected business refusals are result variants. Technical failures leave the current workflow state unchanged.
