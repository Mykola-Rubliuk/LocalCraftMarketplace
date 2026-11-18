# Slice 1 — GRASP decisions

1. **Controller — ReservationService.** It receives the `recordReservation` and `evaluateExpiry` system events and coordinates the reservation workflow. Alternative: make Reservation itself coordinate stock availability and reservation creation. Rejected because the entity would become coupled to external collaborators and service operations.


2. **Information Expert — Reservation.** It owns reservation details, including reservation ID, item code, customer reference, conditions, status and agreed expiry date. It is responsible for maintaining its own reservation state. Alternative: keep all reservation state management in ReservationService. Rejected because the entity's data and related responsibilities would be separated.


3. **Information Expert — ReservationPolicy.** It calculates the agreed reservation expiry date using the approved reservation rules and working-day calculations. Alternative: place expiry calculations directly inside ReservationService. Rejected because it would couple reservation coordination with expiry policy and make policy changes harder to manage.


4. **Pure Fabrication — ReservationRepository.** Persistence and retrieval are not natural responsibilities of Reservation. The repository keeps storage concerns outside the domain entity and provides a dedicated mechanism for managing reservation records.


5. **Indirection / Protected Variations — StockAvailabilityPort and ReservationRepository.** These interfaces isolate stock availability operations and reservation storage from the reservation workflow. They allow different implementations to be introduced without changing ReservationService. StockAvailabilityPort also provides a shared contract for other slices.


6. **High Cohesion / Low Coupling — ReservationPolicy and Clock.** Expiry calculation is isolated within ReservationPolicy, while Clock provides date and working-day information. ReservationService does not need to manage date calculations directly, making the system easier to test and maintain.


7. **Information Expert — ReservationRepository.** It is responsible for retrieving active reservations, locating reservations associated with an item and storing reservation updates. Alternative: make ReservationService manage the underlying collection of reservation records. Rejected because this would mix persistence responsibilities with reservation orchestration.


8. **Consistency as an invariant.** The reservation coordinator must ensure that creating a reservation and changing the item's status to Reserved remain consistent. If reservation creation fails, the item must remain unchanged. Similarly, if stock cannot be reserved, no incomplete reservation should remain. The implementation needs an appropriate transaction boundary or explicit compensation to prevent partial changes.