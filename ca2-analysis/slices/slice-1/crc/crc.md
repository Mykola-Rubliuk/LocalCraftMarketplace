## ReservationService ##
**Responsibilities:**
- Receive and coordinate reservation requests.
- validateRequest(itemCode, customerRef, conditions) — validate the reservation request details, ensuring required customer information and reservation conditions are supplied and valid.
- Check for conflicting active reservations.
- Obtain the current date and time through Clock.
- Coordinate reservation expiry calculation through ReservationPolicy.
- Coordinate reservation creation and persistence.
- Coordinate stock reservation.
- Evaluate reservation expiry and coordinate stock release.
- Return explicit success or rejection results.
- Obtain the signed-in user's ID through CurrentUser and pass it to the new reservation as createdByUserId.
  Collaborators: Reservation, ReservationRepository, ReservationPolicy, StockAvailabilityPort, Clock, CurrentUser.

## Reservation ##
**Responsibilities:**
- Maintain reservationId, itemCode, customer reference, conditions, status and agreed expiry date.
- Maintain reservation status (Active or Expired).
- Identify whether the reservation has expired based on its agreed expiry and the supplied date/time.
- Store createdByUserId to identify the volunteer who created the reservation.
  Collaborators: ReservationService, ReservationPolicy.

## ReservationPolicy ##
**Responsibilities:**
- calculateExpiry(currentDateTime) — calculate the reservation expiry according to the approved reservation policy.
- Apply the approved expiry rules.
- Keep expiry calculations separate from ReservationService.
- Determine the agreed expiry using the supplied current date/time.
  Collaborators: ReservationService, Clock.

## ReservationRepository ##
**Responsibilities:**
- Store and retrieve Reservation records.
- findActiveByItemCode(itemCode) — retrieve an existing active reservation for the selected item to identify conflicting reservations.
- findAllActive() — retrieve all active reservations for expiry evaluation.
- save(reservation) — persist a new reservation.
- update(reservation) — persist reservation status changes.
  Collaborators: ReservationService, Reservation.

## StockAvailabilityPort ##
**Responsibilities:**
- Provide shared stock availability operations and stock state transitions.
- reserveIfAvailable(itemCode) — reserve an item only when its current status is Available.
- releaseIfReserved(itemCode) — release an item only when it is Reserved and no other commitment prevents its release.
- Maintain valid stock states (Available, Reserved or Sold).
- Report ItemNotFound and relevant stock-operation failures.
  Collaborators: ReservationService and other slices.

## Clock ##
**Responsibilities:**
- Clock.now() — provide the current date and time.
- Provide a consistent source of time for reservation operations.
- Support controlled or fixed date/time values during testing.
- Avoid direct system-clock dependencies in reservation logic.
  Collaborators: ReservationService.

## CurrentUser (shared) ##
**Responsibilities:**
- getUserId() — provide the signed-in user's ID.
- Provide identity only; it does not decide what the user is authorised to do.
  Collaborators: ReservationService.