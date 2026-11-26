# **UC-02 — Reserve an item**

**Primary actor:** Shop Volunteer.\
**Goal:** Reserve an available item for a customer and retain an accurate reservation record.\
**Trigger:** A customer asks to reserve an item for later collection or purchase.\
**Related:** US-01; FR-04, FR-05; SC-01, SC-02, SC-03; A-01, A-02; Q-01.

## **Preconditions**

- Processor is authorised to create reservations.
- Item code identifies an existing stock item.
- Customer reference and reservation conditions are supplied.
- Item is currently Available under the shared stock policy.
- No conflicting active reservation exists for the item.
- An approved reservation policy is available to calculate the agreed expiry date.

## **Main success flow**

1. Volunteer submits the item code, customer reference and reservation conditions.
2. ReservationService validates that the required details have been supplied.
3. ReservationService checks that the item exists through StockAvailabilityPort.
4. ReservationService checks the item's current availability.
5. ReservationService checks ReservationRepository for an existing active reservation on the item.
6. ReservationService obtains the current date through Clock.
7. ReservationPolicy calculates the agreed expiry date using the approved reservation rules.
8. ReservationService creates a Reservation record linked to the item and customer, with Active status and the agreed expiry date.
9. ReservationService persists the reservation through ReservationRepository.
10. ReservationService marks the item Reserved through StockAvailabilityPort.
11. System returns `ReservationConfirmed` with the reservation reference and agreed expiry date.

## **Alternative / refusal flows**

- A1 — Missing customer reference: reject with `MissingDetails`; no reservation is created and stock remains unchanged.
- A2 — Missing reservation conditions: reject with `MissingDetails`; no reservation is created and stock remains unchanged.
- A3 — Unknown item: reject with `ItemNotFound`; no reservation is created.
- A4 — Item already Reserved or Sold: reject with `ItemUnavailable`; no reservation is created.
- A5 — Conflicting active reservation: reject with `ConflictingReservation`; no additional reservation is created.
- A6 — Expiry cannot be calculated under the approved policy: reject the request; no reservation or stock status change occurs.
- A7 — Reservation persistence or stock update fails: do not leave a partially completed reservation; reservation and stock state must remain consistent.

## **Postconditions**

**Success:** one Active Reservation exists, linked to the item and customer; an agreed expiry date is recorded; the item is marked Reserved.\
**Failure:** no new Reservation exists; no existing reservation is modified; stock status remains unchanged.

## **Expiry evaluation**

1. ReservationService receives an `evaluateExpiry(asOf)` request.
2. ReservationService retrieves active reservations through ReservationRepository.
3. Each active reservation's agreed expiry date is checked against `asOf`.
4. Reservations whose expiry has been reached or passed are changed to `Expired`.
5. The item is released through StockAvailabilityPort only if no other commitment applies.
6. The system returns the list of reservations that were marked Expired.

## **Expiry postconditions**

**Success:** expired reservations have Expired status; eligible items are released; reservations that have not reached expiry remain Active.\
**Repeated evaluation:** already expired reservations are not processed again, and no duplicate release occurs.

## **Unresolved**

- Confirm the approved reservation expiry policy; the proposed three-working-day policy is currently only used by the fixed test fake.
- Confirm the exact boundary rule for expiry, such as whether a reservation expires at the start or end of the agreed expiry date.
- Confirm how the system determines whether another commitment prevents an item from being released.
- Confirm how reservation creation and stock status updates are kept atomic if one operation fails.
- Confirm whether customer reference and reservation conditions are always mandatory.