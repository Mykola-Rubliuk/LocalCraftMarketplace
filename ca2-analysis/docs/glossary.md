# Shared glossary

| Term | Meaning |
|---|---|
| Product | A craft design/type with description, maker and base selling price |
| Stock item | A distinguishable physical item or stock unit tracked for availability |
| Item code | Stable identifier used by the shared stock interface |
| Reservation | A recorded commitment of an item to a customer under agreed conditions |
| Active reservation | Reservation that has not expired, been cancelled or otherwise closed |
| Customer order | A customer's request containing one or more order lines |
| Order line | One product/item commitment within an order, with its own fulfilment state |
| Sale | Completed transaction record containing one or more sale lines |
| Sale line | Item-level sale evidence including price, quantity, discount and maker attribution |
| Offline transaction | Event transaction captured while normal connectivity is unavailable |
| Reconciliation | Validation and controlled posting of an offline transaction into the central records |
| Port | An interface boundary used by a service to depend on a capability without owning its implementation |
| Fake | A simple in-memory test implementation of a port or repository |
| Atomic sale | Sale operation in which all requested lines succeed together or none are committed |
| Agreed expiry | Expiry date/time recorded for a reservation; it is not automatically a universal policy duration |
