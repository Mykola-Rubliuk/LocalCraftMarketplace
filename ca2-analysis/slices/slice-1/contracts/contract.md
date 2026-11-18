# Slice 1 — Operation contract

## OC-1.1 recordReservation(itemCode, customerRef, conditions)

**Preconditions**

- itemCode identifies an existing item in StockAvailabilityPort.
- customerRef identifies the customer requesting the reservation.
- conditions are supplied and contain all required reservation details.
- The item status is Available.
- No other active reservation exists for the same item.
- The reservation expiry can be calculated through the approved ReservationPolicy.

**Postconditions on success**

- One Reservation is created with a unique reservationId.
- The Reservation is linked to the relevant item and customer.
- The Reservation status is set to Active.
- The agreed expiry date is calculated using ReservationPolicy.
- The item status is changed from Available to Reserved through StockAvailabilityPort.
- The Reservation is successfully stored through ReservationRepository.

**Failure guarantee**

- No Reservation is created.
- No existing Reservation is modified.
- The item stock status remains unchanged.
- Result identifies ItemUnavailable, ConflictingReservation or MissingDetails.
- An unknown item results in ItemNotFound.

# OC-1.2 evaluateExpiry(asOf)

**Preconditions**

- asOf provides the date used to evaluate reservation expiry.
- Active reservations can be retrieved through ReservationRepository.
- Each active reservation has an agreed expiry date.
- Stock availability can be checked and updated through StockAvailabilityPort.

**Postconditions on success**

- All active reservations whose agreed expiry date has been reached or passed are identified.
- Each identified Reservation has its status changed from Active to Expired.
- Each expired reservation is returned in the result.
- The associated item is released through StockAvailabilityPort if no other commitment applies.
- Reservations that have not reached their agreed expiry date remain Active.
- Repeated execution does not expire or release the same reservation more than once.

**Failure guarantee**

- Reservations that have not expired remain unchanged.
- No reservation is incorrectly marked as expired.
- Items with another commitment are not released.
- Expiry evaluation does not create duplicate reservations or modify unrelated records.