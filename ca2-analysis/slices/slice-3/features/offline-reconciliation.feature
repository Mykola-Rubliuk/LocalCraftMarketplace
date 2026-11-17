@UC-10 @Slice3
Feature: Reconcile offline transactions
  As a market coordinator
  I want to enter and reconcile sales recorded during an internet outage
  So that no market transaction remains unaccounted for

  Background:
    Given the market coordinator is signed in
    And stock item "CER-103" is available
    And stock item "CER-105" is recorded as sold

  Rule: Offline transactions are recorded for later reconciliation

    @SC-11
    Scenario: Enter an offline transaction
      When the market coordinator enters offline reference "OFF-03" dated "2026-11-14" for "CER-103" at 25.00
      Then "OFF-03" is recorded as awaiting reconciliation
      And the offline reference, date and market coordinator are recorded

    Scenario: Refuse an offline transaction with missing details
      When the market coordinator enters offline reference "OFF-05" with no items
      Then the entry is refused
      And the missing details are listed
      And no offline transaction is recorded for "OFF-05"

    Scenario: A re-sent entry does not create a duplicate
      Given the market coordinator has entered "OFF-03" with submission "SUB-1"
      When the same submission "SUB-1" is sent again
      Then only one offline transaction "OFF-03" exists
      And it is awaiting reconciliation

  Rule: Offline transactions are reconciled when connectivity returns

    @SC-12
    Scenario: Reconcile an offline transaction without conflicts
      Given offline transaction "OFF-03" for "CER-103" is awaiting reconciliation
      When the market coordinator reconciles "OFF-03"
      Then a sale for "CER-103" is recorded from "OFF-03"
      And stock item "CER-103" is no longer shown as available
      And "OFF-03" is recorded as reconciled

    Scenario: Reconciling the same offline transaction twice
      Given offline transaction "OFF-03" has already been reconciled
      When the market coordinator reconciles "OFF-03" again
      Then the request is refused
      And only one sale is recorded from "OFF-03"

    Scenario: Sale recording times out
      Given offline transaction "OFF-03" for "CER-103" is awaiting reconciliation
      And sale recording is unavailable
      When the market coordinator reconciles "OFF-03"
      Then "OFF-03" is still awaiting reconciliation
      And no sale is recorded from "OFF-03"

  Rule: Duplicates and conflicts are referred to the manager and record no sale

    @SC-13
    Scenario: Refer a duplicate offline transaction
      Given offline transaction "OFF-03" has already been reconciled
      When the market coordinator enters offline reference "OFF-03" again
      Then the entry is flagged as a possible duplicate
      And no second sale is recorded
      And the entry is recorded as referred to the manager

    @SC-14
    Scenario: Refer an offline transaction that conflicts with existing records
      Given offline transaction "OFF-04" for "CER-105" is awaiting reconciliation
      When the market coordinator reconciles "OFF-04"
      Then "OFF-04" is recorded as referred to the manager with reason "item already sold"
      And no additional sale is recorded for "CER-105"

    Scenario: Refer an offline transaction for a reserved item
      Given stock item "CER-106" has an active reservation for a customer
      And offline transaction "OFF-06" for "CER-106" is awaiting reconciliation
      When the market coordinator reconciles "OFF-06"
      Then "OFF-06" is recorded as referred to the manager with reason "item reserved"
      And no sale is recorded from "OFF-06"

    Scenario: No line is sold when one line conflicts
      Given offline transaction "OFF-07" for "CER-103" and "CER-105" is awaiting reconciliation
      When the market coordinator reconciles "OFF-07"
      Then "OFF-07" is recorded as referred to the manager
      And stock item "CER-103" is still available

  Rule: The manager resolves referred offline transactions

    @SC-15
    Scenario: Manager resolves a referred offline transaction
      Given offline transaction "OFF-04" is referred to the manager
      When the manager records the decision "rejected" with the note "item already sold in the shop"
      Then "OFF-04" is recorded as resolved with the decision and note
      And no sale is recorded from "OFF-04"

    Scenario: Only a manager may resolve a referred offline transaction
      Given offline transaction "OFF-04" is referred to the manager
      When the market coordinator tries to resolve "OFF-04"
      Then the request is refused
      And "OFF-04" is still referred to the manager