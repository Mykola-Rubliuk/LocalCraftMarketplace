# Slice 1 — Manage a Reservation (UC-02)

**Working owner:** Marian Andrei  
**Controller / Provider:** `ReservationService`  
**Shared interfaces used:** `StockAvailabilityPort`, `Clock`

## Purpose

This slice creates reservations for available stock items, records the customer and agreed expiry details, and evaluates expiry. An expired item is released only when no other commitment applies.

## Provides / requires

**Provides**
- `ReservationService.recordReservation(...)`
- `ReservationService.evaluateExpiry(...)`

**Requires**
- `ReservationRepository`
- `StockAvailabilityPort`
- `ReservationPolicy`
- `Clock`

## Shared interaction with other slices

- Use `StockAvailabilityPort.getStatus(itemCode)` and the shared statuses `Available`, `Reserved`, `Sold`, `Unknown`.
- Use `reserveIfAvailable(itemCode)` to make the Available → Reserved transition.
- Use `releaseIfReserved(itemCode)` when an expired reservation may be released.
- Slice 3 reads stock through `getStatus` and treats Reserved as an offline conflict.
- Slice 4 reads stock through `getStatus` and does not sell Reserved items unless Q-SH-01 is resolved and the shared contract is changed.

## Scope

**In scope:** reservation creation, validation, active-reservation conflict checks, policy-based expiry calculation, expiry evaluation and release of eligible items.

**Out of scope:** sales, customer orders, product maintenance, commissions and offline reconciliation.

## Main artefacts

- [Use case](use-case.md)
- [Operation contracts](../contracts/contract.md)
- [CRC cards](../crc/crc.md)
- [GRASP decisions](../grasp/grasp.md)
- [Gherkin scenarios](../features/reservation.feature)
- [Reserve item sequence](../sequence/Reserve-Item.puml)
- [Expiry evaluation sequence](../sequence/Expiry-evaluation.puml)

## Consistency and failure handling

A reservation must not be reported as successful unless both its record and stock transition have succeeded. An expiry must not be reported as complete unless reservation state and stock state are consistent. The group must agree the transaction/compensation mechanism across ReservationRepository and stock persistence.

## Open questions

- Q-01 / Q-SH-03: approved expiry policy and working-day calendar.
- Exact expiry boundary rule.
- How to determine whether another commitment prevents release.
- Whether customer reference and reservation conditions are always mandatory.

The three-working-day example in the feature file is a test fixture only, not an approved policy.
