# Slice 1 — Feature: Reserve an item

Feature: Reserve an item
  As a Shop Volunteer
  I want to reserve an available item for a customer
  So that the customer can collect or purchase the item within the agreed reservation period

  Scenario: Successfully reserve an available item
    Given item "IT-201" exists and is available
    And customer "CU-001" provides all required reservation details
    When the volunteer records a reservation for item "IT-201"
    Then a reservation is created with status "Active"
    And the reservation is linked to customer "CU-001"
    And an agreed expiry date is assigned
    And item "IT-201" becomes reserved
    And the reservation records the ID of the volunteer who created it


  Scenario: Reject a reservation for an unavailable item
    Given item "IT-202" is already sold
    And no active reservation exists for item "IT-202"
    And customer "CU-002" provides all required reservation details
    When the volunteer attempts to reserve item "IT-202"
    Then the request is rejected with "ItemUnavailable"
    And no reservation is created
    And item "IT-202" remains sold

  Scenario: Reject a conflicting reservation
    Given item "IT-203" is already reserved
    And an active reservation exists for item "IT-203"
    When the volunteer attempts to reserve item "IT-203" for another customer
    Then the request is rejected with "ConflictingReservation"
    And no additional reservation is created
    And item "IT-203" remains reserved

  Scenario: Reject a reservation with missing customer details
    Given item "IT-204" is available
    And the customer reference is missing
    When the volunteer attempts to reserve item "IT-204"
    Then the request is rejected with "MissingDetails"
    And no reservation is created
    And item "IT-204" remains available

  Scenario: Reject a reservation with missing conditions
    Given item "IT-205" is available
    And the reservation conditions are missing
    When the volunteer attempts to reserve item "IT-205"
    Then the request is rejected with "MissingDetails"
    And no reservation is created
    And item "IT-205" remains available

  Scenario: Reject a reservation for an unknown item
    Given item "IT-206" does not exist
    When the volunteer attempts to reserve item "IT-206"
    Then the request is rejected with "ItemNotFound"
    And no reservation is created

  Scenario: Calculate reservation expiry using the approved policy
    Given item "IT-207" is available
    And the approved reservation policy allows 3 working days
    And the current date is Monday
    When the volunteer records a reservation for item "IT-207"
    Then the reservation is assigned an expiry date of Thursday
    And the reservation status is "Active"

  Scenario: Reject a reservation when persistence fails
    Given item "IT-212" is available
    And customer "CU-003" provides all required reservation details
    And the reservation repository is unable to save the reservation
    When the volunteer attempts to reserve item "IT-212"
    Then the request is rejected with "PersistenceFailed"
    And no reservation is stored
    And item "IT-212" remains available

  Scenario: Roll back a reservation when stock update fails
    Given item "IT-213" is available
    And customer "CU-004" provides all required reservation details
    And the reservation is successfully saved
    And the stock reservation operation fails
    When the volunteer attempts to reserve item "IT-213"
    Then the request is rejected with "StockUpdateFailed"
    And the newly created reservation is rolled back
    And item "IT-213" remains available

  Scenario: Reject a reservation when the stock service is unavailable
    Given item "IT-214" is available
    And customer "CU-005" provides all required reservation details
    And the stock service is unavailable
    When the volunteer attempts to reserve item "IT-214"
    Then the request is rejected with "StockServiceUnavailable"
    And no incomplete reservation remains
    And item "IT-214" remains available

  Scenario: Keep a reservation active before its expiry date
    Given an active reservation exists for item "IT-208"
    And its agreed expiry date is Wednesday
    When the system evaluates expiry on Tuesday
    Then the reservation remains "Active"
    And item "IT-208" remains reserved

  Scenario: Expire a reservation when its expiry date is reached
    Given an active reservation exists for item "IT-209"
    And its agreed expiry date is Wednesday
    And no other commitment applies to item "IT-209"
    When the system evaluates expiry on Wednesday
    Then the reservation status changes to "Expired"
    And item "IT-209" becomes available

  Scenario: Do not release stock when another commitment exists
    Given an active reservation exists for item "IT-215"
    And its agreed expiry date has been reached
    And another commitment applies to item "IT-215"
    When the system evaluates expiry
    Then the reservation status changes to "Expired"
    And item "IT-215" remains reserved
    And the other commitment is not affected

  Scenario: Keep reservation active when stock release fails
    Given an active reservation exists for item "IT-216"
    And its agreed expiry date has been reached
    And the stock release operation fails
    When the system evaluates expiry
    Then the expiry operation reports "StockUpdateFailed"
    And the reservation remains "Active"
    And item "IT-216" remains reserved

  Scenario: Handle an unavailable stock service during expiry evaluation
    Given an active reservation exists for item "IT-217"
    And its agreed expiry date has been reached
    And the stock service is unavailable
    When the system evaluates expiry
    Then the expiry operation reports "StockServiceUnavailable"
    And the reservation remains "Active"
    And item "IT-217" remains reserved

  Scenario: Skip weekends when calculating reservation expiry
    Given item "IT-210" is available
    And the current date is Friday
    And the approved reservation policy allows 3 working days
    When the volunteer records a reservation for item "IT-210"
    Then the agreed expiry date is Wednesday
    And Saturday and Sunday are excluded from the calculation

  Scenario: Evaluate an expired reservation more than once
    Given an active reservation exists for item "IT-211"
    And its agreed expiry date has passed
    When the system evaluates expiry twice
    Then the reservation remains "Expired"
    And the item is not released more than once
    And no duplicate expiry changes are recorded