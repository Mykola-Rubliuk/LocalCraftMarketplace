# UC-02 — Manage a Reservation

**Primary actor:** Shop Volunteer.  
**Goal:** Reserve an available item for a customer and retain an accurate reservation record.  
**Trigger:** A customer asks to reserve an item for later collection or purchase.  
**Related:** US-01; FR-04, FR-05; SC-01, SC-02, SC-03; Q-01, Q-SH-03.

## Preconditions
- The processor is authorised to create reservations.
- Customer reference and required reservation conditions are supplied.
- `itemCode` is checked through the shared `StockAvailabilityPort`.
- The item's status is `Available`.
- No active reservation already exists for the item.
- An approved `ReservationPolicy` is available.

## Main success flow
1. Volunteer submits `itemCode`, customer reference and reservation conditions.
2. `ReservationService` validates the required details.
3. `ReservationService` calls `StockAvailabilityPort.getStatus(itemCode)`.
4. `ReservationService` checks `ReservationRepository` for an active reservation.
5. `ReservationService` obtains the current time through `Clock.now()`.
6. `ReservationPolicy` calculates the agreed expiry using the approved policy/calendar.
7. `ReservationService` creates the Reservation with Active status.
8. `ReservationService` requests `StockAvailabilityPort.reserveIfAvailable(itemCode)`.
9. The reservation and stock transition are persisted consistently.
10. System returns `ReservationConfirmed(reservationId, agreedExpiry)`.

## Alternative / refusal flows
- A1 — Missing customer reference or conditions: reject with `MissingDetails`; no reservation or stock change.
- A2 — Unknown item: reject with `ItemNotFound`; no reservation.
- A3 — Item is Reserved or Sold: reject with `ItemUnavailable`; no reservation.
- A4 — Active reservation exists while stock appears Available: reject with `ConflictingReservation`; no stock change.
- A5 — Expiry cannot be calculated: reject with `ReservationPolicyUnavailable`; no reservation or stock change.
- A6 — Atomic reserve operation rejects because availability changed: reject with `ItemUnavailable`; no reservation is committed.
- A7 — Persistence or stock update fails: report a technical failure and do not leave a partial reservation/stock change.

## Postconditions
**Success:** one Active Reservation exists, linked to the item and customer; an agreed expiry is recorded; stock status is Reserved.  
**Failure:** no new Reservation is committed; stock status remains unchanged.

## Expiry evaluation
1. `ReservationService` receives `evaluateExpiry(asOf)`; `asOf` may be supplied by the caller or obtained from `Clock.now()`.
2. It retrieves active reservations from `ReservationRepository`.
3. It compares each agreed expiry with `asOf`.
4. An eligible reservation is changed to Expired.
5. `StockAvailabilityPort.releaseIfReserved(itemCode)` is called only when no other commitment applies.
6. The system returns the reservations successfully expired.

## Expiry postconditions
**Success:** eligible reservations are Expired and their items are released where permitted. Reservations not yet expired remain Active. Repeated evaluation does not repeat the transition.

## Unresolved
- Confirm the approved expiry policy and working-day calendar (Q-01, Q-SH-03).
- Confirm the exact boundary rule for expiry.
- Confirm how the system checks for another commitment before releasing an item.
- Confirm the transaction/compensation mechanism across ReservationRepository and StockAvailabilityPort.
- Confirm whether customer reference and reservation conditions are always mandatory.
