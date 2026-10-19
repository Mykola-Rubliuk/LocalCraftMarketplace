Feature: Marketplace commitments and order records
  The cooperative needs consistent records of reservations, fulfilment and commissions.

  Rule: An item cannot have two conflicting active reservations

    @SC-01 @FR-04 @FR-05 @UC-02 @US-01
    Scenario: Reserve an available one-off item
      Given stock item "CER-101" is available
      And customer "C-07" requests a reservation
      When the volunteer records a reservation for "CER-101"
      Then an active reservation for customer "C-07" is recorded
      And stock item "CER-101" is not shown as available

    @SC-02 @FR-04 @FR-05 @UC-02 @US-01
    Scenario: Reject a second active reservation
      Given stock item "CER-101" has an active reservation for customer "C-07"
      When the volunteer requests another reservation for customer "C-08"
      Then the second reservation is rejected
      And the existing reservation remains active

  Rule: Expiry is governed by an approved reservation policy

    @SC-03 @FR-05 @UC-02 @US-01
    Scenario: Expire an unpaid reservation at the proposed boundary
      Given the manager has approved a three-working-day unpaid reservation rule
      And an unpaid reservation has reached the end of its third working day
      When the reservation expiry is evaluated
      Then the reservation is recorded as expired
      And the stock item becomes available if no other commitment applies

  Rule: Order lines have independent fulfilment status

    @SC-04 @FR-06 @FR-07 @UC-04 @US-02
    Scenario: Record partial collection without completing the whole order
      Given order "ORD-20" contains line "L1" ready for collection
      And order "ORD-20" contains line "L2" still being made
      When the volunteer records collection of line "L1"
      Then line "L1" is recorded as collected
      And line "L2" remains recorded as still being made
      And order "ORD-20" is not recorded as fully fulfilled

  Rule: Material commission changes require recorded approval

    @SC-05 @FR-08 @UC-05 @US-03
    Scenario: Do not apply an unapproved commission price change
      Given commission "COM-9" has an agreed price of 80 euro
      And a maker proposes a revised price of 95 euro
      When the proposed change is recorded without customer approval
      Then the agreed price remains 80 euro
      And the proposed change is marked as awaiting approval
