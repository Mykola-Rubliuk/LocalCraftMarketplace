Feature: Marketplace commitments and order records
  The cooperative needs consistent records of reservations, fulfilment and commissions.

  Rule: An item cannot have two conflicting active reservations

    @SC-01
    Scenario: Reserve an available one-off item
      Given stock item "CER-101" is available
      And customer "C-07" requests a reservation
      When the volunteer records a reservation for "CER-101"
      Then an active reservation for customer "C-07" is recorded
      And stock item "CER-101" is not shown as available

    @SC-02
    Scenario: Reject a second active reservation
      Given stock item "CER-101" has an active reservation for customer "C-07"
      When the volunteer requests another reservation for customer "C-08"
      Then the second reservation is rejected
      And the existing reservation remains active

  Rule: Expiry is governed by an approved reservation policy

    @SC-03
    Scenario: Expire an unpaid reservation at the proposed boundary
      Given the manager has approved a three-working-day unpaid reservation rule
      And an unpaid reservation has reached the end of its third working day
      When the reservation expiry is evaluated
      Then the reservation is recorded as expired
      And the stock item becomes available if no other commitment applies

  Rule: Order lines have independent fulfilment status

    @SC-04
    Scenario: Record partial collection without completing the whole order
      Given order "ORD-20" contains line "L1" ready for collection
      And order "ORD-20" contains line "L2" still being made
      When the volunteer records collection of line "L1"
      Then line "L1" is recorded as collected
      And line "L2" remains recorded as still being made
      And order "ORD-20" is not recorded as fully fulfilled

  Rule: Material commission changes require recorded approval

    @SC-05
    Scenario: Do not apply an unapproved commission price change
      Given commission "COM-9" has an agreed price of 80 euro
      And a maker proposes a revised price of 95 euro
      When the proposed change is recorded without customer approval
      Then the agreed price remains 80 euro
      And the proposed change is marked as awaiting approval

        Rule: Stock movements must be recorded consistently

    @SC-06
    Scenario: Record an item movement to the shop
      Given stock item "CER-102" is held by its maker
      When the market coordinator records its movement to the shop
      Then the stock movement is recorded with the item and destination
      And the item's current location is recorded as the shop

  Rule: Completed sales must update stock records

    @SC-07
    Scenario: Record a sale of an available item
      Given stock item "CER-103" is available
      And the item has a recorded selling price of 25 euro
      When the volunteer records a completed sale of "CER-103"
      Then the sale is recorded with the item and selling price
      And the item is no longer shown as available

  Rule: Confidential maker-payment information is restricted

    @SC-08
    Scenario: Prevent a volunteer from viewing maker-payment summaries
      Given a volunteer is signed in to the system
      When the volunteer attempts to view confidential maker-payment summaries
      Then access to the summaries is denied
      And the volunteer can still access authorised sales functions

  Rule: Return requests must be recorded for review

    @SC-09
    Scenario: Record a customer return request
      Given a customer reports a problem with an item from sale "SALE-12"
      When the volunteer records the return request and its reason
      Then the return request is saved with the relevant sale reference
      And the request is available for manager review

  Rule: Makers can maintain only authorised product records

    @SC-10
    Scenario: Maker updates their own product information
      Given maker "M-01" has an existing product record "CER-104"
      When the maker updates the product description and price
      Then the updated information is recorded for "CER-104"
      And the product information is available to authorised staff

  Rule: Market transactions must be accounted for during internet outages

    @SC-11
    Scenario: Record a transaction during an internet outage
      Given internet access is unavailable at the market
      And the documented offline recording procedure is available
      When the market coordinator records a transaction using that procedure
      Then the transaction details are recorded for later reconciliation
      And the transaction is identified as awaiting reconciliation