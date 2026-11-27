# Slice 1 — GRASP decisions #

1. **Controller — ReservationService.** It receives the recordReservation and evaluateExpiry system events and coordinates the reservation workflow. Alternative: make Reservation itself coordinate stock availability and reservation creation. Rejected because the entity would become coupled to external collaborators and service operations.


2. **Information Expert — Reservation.** It owns reservation details, including reservation ID, item code, customer reference, conditions, status and agreed expiry date. It is responsible for maintaining its own reservation state. Alternative: keep all reservation state management in ReservationService. Rejected because the entity's data and related responsibilities would be separated.


3. **Information Expert — ReservationPolicy.** It calculates the agreed reservation expiry date using the approved reservation rules and supplied current date and time. Working-day calculations and expiry rules belong here rather than in ReservationService or Clock. Alternative: place expiry calculations directly inside ReservationService. Rejected because it would couple reservation coordination with expiry policy and make policy changes harder to manage.


4. **Pure Fabrication — ReservationRepository.** Persistence and retrieval are not natural responsibilities of Reservation. The repository keeps storage concerns outside the domain entity and provides a dedicated mechanism for managing reservation records. Its findActiveByItemCode() method retrieves an existing active reservation for a selected item, while findAllActive() retrieves active reservations for expiry evaluation. Its save() and update() methods handle reservation persistence.


5. **Indirection / Protected Variations — StockAvailabilityPort.** It isolates stock operations from the reservation workflow through a shared interface. Its reserveIfAvailable() method reserves an item only when it is available, while releaseIfReserved() releases eligible reserved stock only when no other commitment prevents its release. This allows stock transitions to be managed consistently without coupling ReservationService to the underlying stock implementation.


6. **Protected Variations — Clock.** Clock acts as a shared time abstraction through its now() method, providing the current date and time to reservation operations. It avoids direct dependencies on the system clock and allows fixed or controlled time values to be supplied during testing. Alternative: retrieve the system date and time directly wherever needed. Rejected because this would make time-dependent behaviour harder to control and test.


7. **Information Expert — ReservationRepository.** It is responsible for retrieving active reservations, locating reservations associated with an item and storing reservation updates. Alternative: make ReservationService manage the underlying collection of reservation records. Rejected because this would mix persistence responsibilities with reservation orchestration.


8. **Consistency as an invariant.** The reservation coordinator must ensure that creating a reservation and changing the item's status to Reserved remain consistent. If reservation creation fails, the item must remain unchanged. Similarly, if stock cannot be reserved, no incomplete reservation should remain. During expiry evaluation, the reservation must not become Expired unless the corresponding stock operation succeeds or an appropriate consistency strategy is applied. The implementation needs an appropriate transaction boundary or explicit compensation to prevent partial changes.


9. **Indirection — CurrentUser (D-CA2-20).** It sits between ReservationService and however sign-in works, providing the signed-in user's ID through getUserId(). ReservationService passes the ID to Reservation as a value, so Reservation does not depend on CurrentUser. Alternative: pass userId as an input to recordReservation. Rejected because the design would then have to ensure the supplied ID belongs to the signed-in user.