Feature: Process a customer sale
  As a Shop Volunteer
  I want to record a customer sale
  So that the cooperative has accurate sales and maker-attribution evidence

  Scenario: Record a sale containing items from two makers
    Given item "IT-201" is available and belongs to maker "MK-1"
    And item "IT-202" is available and belongs to maker "MK-2"
    When the volunteer records a sale with both items
    Then a completed sale is recorded
    And each sale line retains its maker attribution
    And both items become sold

  Scenario: Reject a sale with no lines
    Given the sale request contains no lines
    When the volunteer records the sale
    Then the request is rejected with "NoLines"
    And no sale is created

  Scenario: Reject the entire sale when one item is unavailable
    Given item "IT-204" is available
    And item "IT-205" is already sold
    When the volunteer records a sale containing both items
    Then the request is rejected with "ItemUnavailable"
    And no sale is created
    And item "IT-204" remains available

  Scenario: Reject an item without maker attribution
    Given item "IT-206" has no maker attribution
    When the volunteer records a sale containing item "IT-206"
    Then the request is rejected with "MissingMakerAttribution"
    And no sale is created

  Scenario: Reject a sale containing an unknown item
    Given item "IT-207" does not exist in the product catalogue
    When the volunteer records a sale containing item "IT-207"
    Then the request is rejected with "ItemNotFound"
    And no sale is created

  Scenario: Reject a sale with an invalid quantity
    Given item "IT-208" is available
    When the volunteer records a sale with quantity 0 for item "IT-208"
    Then the request is rejected with "InvalidQuantity"
    And no sale is created
    And item "IT-208" remains available

  Scenario: Reject a sale with an invalid price
    Given item "IT-209" is available
    When the volunteer records a sale with a negative price for item "IT-209"
    Then the request is rejected with "InvalidPrice"
    And no sale is created
    And item "IT-209" remains available

  Scenario: Reject a sale with an invalid discount
    Given item "IT-210" is available
    When the volunteer records a sale with a discount exceeding the permitted amount
    Then the request is rejected with "InvalidDiscount"
    And no sale is created
    And item "IT-210" remains available

  Scenario: Reject a sale by an unauthorised processor
    Given the user is not authorised to process sales
    And item "IT-211" is available
    When the user attempts to record a sale containing item "IT-211"
    Then the request is rejected with "UnauthorisedProcessor"
    And no sale is created
    And item "IT-211" remains available
