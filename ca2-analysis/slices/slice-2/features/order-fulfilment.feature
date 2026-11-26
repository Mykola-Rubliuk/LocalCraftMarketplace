@UC-04 @Slice2
Feature: Fulfil order lines

  Background:
    Given the shop volunteer is authorised
    And order "O-105" exists with order lines "L-12" and "L-13"

  @BR-03 @FR-07
  Rule: Item-level readiness must be distinguishable within an order

    @SC-04
    Scenario Outline: Progress update leaves other lines unchanged
      Given order line "L-12" has status "<current>"
      And order line "L-13" has status "<other>"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      Then order line "L-12" has status "<new>"
      And order line "L-13" still has status "<other>"

      Examples:
        | current   | new       | other     |
        | BeingMade | Ready     | BeingMade |
        | Ready     | Collected | Ready     |

    Scenario Outline: Customer decision leaves other lines unchanged
      Given order line "L-12" has status "<current>"
      And order line "L-13" has status "<other>"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      And supplies a valid reason
      Then order line "L-12" has status "<new>"
      And order line "L-13" still has status "<other>"

      Examples:
        | current   | new         | other     |
        | BeingMade | Cancelled   | Ready     |
        | Ready     | Substituted | BeingMade |

  Rule: An order's status reflects the statuses of its lines

    Scenario Outline: Closing the last open line completes the order
      Given order line "L-12" has status "<current>"
      And order line "L-13" has status "<other>"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      And supplies a valid reason if the new status requires one
      Then order "O-105" is "Completed"

      Examples:
        | current   | new         | other       |
        | BeingMade | Cancelled   | Collected   |
        | BeingMade | Substituted | Collected   |
        | Ready     | Collected   | Collected   |
        | Ready     | Cancelled   | Cancelled   |
        | Ready     | Substituted | Substituted |

    Scenario: An order with an open line is not "Completed"
      Given order line "L-12" has status "Ready"
      And order line "L-13" has status "BeingMade"
      When the shop volunteer changes the status of order line "L-12" to "Collected"
      Then order "O-105" is not "Completed"

  @D-CA2-15
  Rule: A customer decision must be recorded with a reason

    Scenario Outline: A decision with a reason is recorded
      Given order line "L-12" has status "<current>"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      And supplies the reason "<reason>"
      Then order line "L-12" has status "<new>"
      And the decision reason of order line "L-12" is "<reason>"

      # Reason values are placeholders until the predefined list is agreed
      Examples:
        | current   | new         | reason          |
        | BeingMade | Cancelled   | ChangedMind     |
        | BeingMade | Substituted | ItemUnavailable |
        | Ready     | Cancelled   | ChangedMind     |
        | Ready     | Substituted | ItemUnavailable |

    Scenario: NotGiven is accepted as a reason
      Given order line "L-12" has status "Ready"
      When the shop volunteer changes the status of order line "L-12" to "Cancelled"
      And supplies the reason "NotGiven"
      Then order line "L-12" has status "Cancelled"
      And the decision reason of order line "L-12" is "NotGiven"

    Scenario Outline: A decision without a reason is rejected
      Given order line "L-12" has status "<current>"
      When the shop volunteer changes the status of order line "L-12" to "<new>" without supplying a reason
      Then the result is "Rejected(ReasonNotSupplied)"
      And order line "L-12" still has status "<current>"
      And the status of order "O-105" is unchanged
      And no decision reason is recorded

      Examples:
        | current   | new         |
        | BeingMade | Cancelled   |
        | BeingMade | Substituted |
        | Ready     | Cancelled   |
        | Ready     | Substituted |

  Rule: An order line's status can change only through an allowed transition

    Scenario Outline: An allowed status change is accepted
      Given order line "L-12" has status "<current>"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      And supplies a valid reason if the new status requires one
      Then order line "L-12" has status "<new>"
      And a decision reason is recorded only if the new status requires one

      Examples:
        | current   | new         |
        | BeingMade | Ready       |
        | BeingMade | Cancelled   |
        | BeingMade | Substituted |
        | Ready     | Collected   |
        | Ready     | Cancelled   |
        | Ready     | Substituted |

    Scenario Outline: A status change that is not allowed is rejected
      Given order line "L-12" has status "<current>"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      And supplies a valid reason if the new status requires one
      Then the result is "Rejected(InvalidStatusChange)"
      And order line "L-12" still has status "<current>"
      And the status of order "O-105" is unchanged
      And no new decision reason is recorded

      Examples:
        | current     | new       |
        | BeingMade   | Collected |
        | Ready       | BeingMade |
        | Collected   | Cancelled |
        | Cancelled   | Ready     |
        | Substituted | Collected |

  @A-04 @D-CA2-14
  Rule: An order line records who made the last change and when

    Scenario Outline: A status change records who made it and when
      Given order line "L-12" has status "<current>"
      And the last change of order line "L-12" was made by "SV-2" at "2026-11-25 15:00"
      And the shop volunteer making the change is "SV-1"
      And the current time is "2026-11-26 10:00"
      When the shop volunteer changes the status of order line "L-12" to "<new>"
      And supplies a valid reason if the new status requires one
      Then the last change of order line "L-12" was made by "SV-1" at "2026-11-26 10:00"

      Examples:
        | current   | new       |
        | BeingMade | Ready     |
        | Ready     | Cancelled |