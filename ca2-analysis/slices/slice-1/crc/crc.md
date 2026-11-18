## ReservationService
**Responsibilities:** receive reservation request; validate customer details and conditions; check item availability; check for conflicting active reservations; calculate agreed expiry through ReservationPolicy; coordinate reservation creation; update item status to Reserved; evaluate reservation expiry; release expired reservations where no other commitment applies; return explicit results.
**Collaborators:** Reservation, ReservationRepository, ReservationPolicy, StockAvailabilityPort, Clock.


## Reservation
**Responsibilities:** know reservationId, itemCode, customer reference, conditions, status and agreed expiry date; maintain reservation status; identify whether the reservation has expired.
**Collaborators:** ReservationService, ReservationPolicy.


## ReservationPolicy
**Responsibilities:** calculate the agreed reservation expiry date; apply the approved expiry rules; ensure expiry calculations are not hard-coded into ReservationService.
**Collaborators:** ReservationService, Clock.


## ReservationRepository
**Responsibilities:** store and retrieve Reservation records; find active reservations by itemCode; retrieve active reservations for expiry evaluation; update reservation status.
**Collaborators:** ReservationService, Reservation.


## StockAvailabilityPort
**Responsibilities:** provide shared stock availability queries and stock state transitions; return item status (Available, Reserved or Sold); mark items Reserved or Sold; release items when appropriate; report ItemNotFound.
**Collaborators:** ReservationService and other slices.


## Clock
**Responsibilities:** provide the current date and time; calculate the number of working days between two dates; support consistent reservation expiry calculations and testing.
**Collaborators:** ReservationService, ReservationPolicy.
