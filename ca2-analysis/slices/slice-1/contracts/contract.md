## OC-1.1 — recordReservation(itemCode, customerRef, conditions, userId) ##
**Preconditions**

- The volunteer is authenticated and authorised to record reservations.
- itemCode identifies an existing item in StockAvailabilityPort.
- customerRef identifies the customer requesting the reservation.
- conditions are supplied and contain all required reservation details.
- The item status is Available.
- No other active reservation exists for the same item.
- The reservation expiry can be calculated through the approved ReservationPolicy.
- ReservationRepository and StockAvailabilityPort are available.


**Postconditions on success**


- The reservation records the ID of the volunteer who created it.
- One Reservation is created with a unique reservationId.
- The Reservation is linked to the relevant item and customer.
- The Reservation status is set to Active.
- The agreed expiry date is calculated using ReservationPolicy.calculateExpiry(currentDateTime).
- The Reservation is successfully stored through ReservationRepository.
- The item status is changed from Available to Reserved through StockAvailabilityPort.reserveIfAvailable().
- A ReservationConfirmed(reservationId, agreedExpiry) result is returned.


  **Failure outcomes**


- MissingDetails — required customer details or reservation conditions are missing or invalid.
- ItemNotFound — the specified item does not exist.
- ConflictingReservation — an active reservation already exists for the selected item.
- ItemUnavailable — the item exists but cannot be reserved because it is already Reserved, Sold or otherwise unavailable, without a conflicting active reservation record.
- PersistenceFailed — the reservation cannot be saved or persisted.
- StockUpdateFailed — the stock reservation operation fails.
- StockServiceUnavailable — the stock service cannot be reached or is unavailable.


  **Failure guarantees**


- No reservation confirmation is returned.
- No existing Reservation is modified.
- If reservation persistence fails, no reservation remains stored and the item stock status remains unchanged.
- If stock reservation fails after the reservation has been saved, the newly created reservation is rolled back.
- If the stock service is unavailable, no incomplete reservation remains.
- An existing active reservation is never overwritten.
- No partial reservation or stock update is left behind.

## OC-1.2 — evaluateExpiry(asOf) ##
**Preconditions**
- asOf provides the date and time used to evaluate reservation expiry.
- Active reservations can be retrieved through ReservationRepository.findAllActive().
- Each active reservation has an agreed expiry date.
- Stock availability can be updated through StockAvailabilityPort.releaseIfReserved().
- ReservationRepository and StockAvailabilityPort are available.


  **Postconditions on success**


- All active reservations whose agreed expiry date has been reached or passed are identified.
- Each eligible expired Reservation has its status changed from Active to Expired.
- Each successfully expired reservation is included in the result.
- The associated item is released through releaseIfReserved(itemCode) only if no other commitment applies.
- If another commitment applies, the reservation becomes Expired but the item remains Reserved.
- Reservations that have not reached their agreed expiry date remain Active.
- Repeated execution does not expire or release the same reservation more than once.


  **Failure outcomes**


- PersistenceFailed — the reservation status update cannot be persisted.
- StockUpdateFailed — the stock release operation fails.
- StockServiceUnavailable — the stock service is unavailable during expiry evaluation.

    
  **Failure guarantees**


- Reservations that have not expired remain unchanged.
- A reservation must not become Expired if its required stock transition fails.
- If stock release fails, the reservation remains Active and the item remains Reserved.
- Items with another commitment are not released.
- If another commitment exists, the reservation can expire without changing the item's Reserved status.
- Expiry evaluation does not create duplicate reservations or modify unrelated records.
- Reservation expiry and stock updates must be performed atomically, using a transaction or reliable compensation mechanism.