@UC-01 @Slice4
Feature: Process a customer sale
  As an authorised Shop Volunteer or Market Coordinator
  I want to record a customer sale
  So that the cooperative has accurate sales and maker-attribution evidence

  @SC-07
  Scenario: Record a sale containing items from two makers
    Given item "IT-201" has stock status "Available" and belongs to maker "MK-1"
    And item "IT-202" has stock status "Available" and belongs to maker "MK-2"
    When the volunteer records an in-store sale containing both items with a unique idempotency key
    Then the result is "Recorded" with a saleRef
    And the sale status is "Completed"
    And each sale line retains its maker attribution
    And both items have stock status "Sold"

  Scenario: Reject a sale with no lines
    Given the sale request contains no lines
    When the volunteer records the sale
    Then the result is "Rejected" with reason "NoLines"
    And no sale is created
    And no stock status changes

  Scenario: Reject the entire sale when one item is unavailable
    Given item "IT-204" has stock status "Available"
    And item "IT-205" has stock status "Sold"
    When the volunteer records a sale containing both items
    Then the result is "Rejected" with reason "ItemUnavailable"
    And no sale is created
    And item "IT-204" remains "Available"
    And item "IT-205" remains "Sold"

  Scenario: Reject an item without maker attribution
    Given item "IT-206" has stock status "Available"
    And item "IT-206" has no maker attribution
    When the volunteer records a sale containing item "IT-206"
    Then the result is "Rejected" with reason "MissingMakerAttribution"
    And no sale is created
    And item "IT-206" remains "Available"

  Scenario: Reject a sale containing an unknown item
    Given item "IT-207" has stock status "Unknown"
    When the volunteer records a sale containing item "IT-207"
    Then the result is "Rejected" with reason "ItemNotFound"
    And no sale is created

  Scenario: Reject a sale with an invalid quantity
    Given item "IT-208" has stock status "Available"
    When the volunteer records a sale with quantity 0 for item "IT-208"
    Then the result is "Rejected" with reason "InvalidQuantity"
    And no sale is created
    And item "IT-208" remains "Available"

  Scenario: Reject a sale with an invalid price
    Given item "IT-209" has stock status "Available"
    When the volunteer records a sale with a negative sold price for item "IT-209"
    Then the result is "Rejected" with reason "InvalidPrice"
    And no sale is created
    And item "IT-209" remains "Available"

  Scenario: Reject a sale with an invalid discount
    Given item "IT-210" has stock status "Available"
    When the volunteer records a sale with a discount that violates the agreed discount rules
    Then the result is "Rejected" with reason "InvalidDiscount"
    And no sale is created
    And item "IT-210" remains "Available"

  Scenario: Reject a sale by an unauthorised processor
    Given the processedBy identifier is not authorised to process sales
    And item "IT-211" has stock status "Available"
    When the processor attempts to record a sale containing item "IT-211"
    Then the result is "Rejected" with reason "UnauthorisedProcessor"
    And no sale is created
    And item "IT-211" remains "Available"

  Scenario: Return the original result when the same request is retried
    Given a sale request with idempotency key "SALE-REQ-01" has already been recorded
    When the same request with key "SALE-REQ-01" is submitted again
    Then the original saleRef is returned
    And no second sale is created

  Scenario: Reject reuse of an idempotency key with different data
    Given idempotency key "SALE-REQ-02" has been used for a sale request
    When a different sale request is submitted with key "SALE-REQ-02"
    Then the result is "Rejected" with reason "IdempotencyKeyConflict"
    And no additional sale is created

  Scenario: Accept the actual sale date from an offline form
    Given item "IT-212" has stock status "Available"
    And an offline sale request contains sale date "2026-11-14"
    When the Market Coordinator submits the request through SaleRecordingPort
    Then the sale stores saleDate "2026-11-14"
    And the system stores the current time separately as recordedAt
    And the item has stock status "Sold"