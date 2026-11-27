@UC-10 @Slice3
Feature: Reconcile offline transactions
  As a market coordinator
  I want to enter and reconcile sales recorded during an internet outage
  So that no market transaction remains unaccounted for

  Background:
    Given the market coordinator "MC-1" is signed in
    And stock item "CER-103" is Available
    And stock item "CER-105" is Sold

  Rule: Offline transactions are entered for later reconciliation

    @SC-11
    Scenario: Enter an offline transaction
      When the market coordinator enters submission "SUB-1" with offline reference "OFF-03" dated "2026-11-14" for 1 x "CER-103" at 25.00
      Then the result is OfflineOperationSuccess
      And a new entry "E-03" is recorded as AwaitingReconciliation
      And the offline reference, sale date and recordedAt are stored
      And recordedBy is "MC-1"

    Scenario: Refuse an offline transaction with missing details
      When the market coordinator enters submission "SUB-5" with offline reference "OFF-05" and no lines
      Then the result is OfflineOperationRejected with reason "InvalidOfflineEntry"
      And the invalid fields are listed
      And no entry is stored for "OFF-05"

    Scenario: A re-sent submission does not create a duplicate
      Given submission "SUB-1" has been entered as entry "E-03"
      When submission "SUB-1" is sent again
      Then entry "E-03" is returned
      And only one entry exists for offline reference "OFF-03"

  Rule: Clean offline transactions are recorded as one sale

    @SC-12
    Scenario: Reconcile an offline transaction without conflicts
      Given entry "E-03" for "CER-103" is AwaitingReconciliation
      And no sale has been recorded for idempotency key "E-03"
      When the market coordinator reconciles entry "E-03"
      Then a SaleRequest with idempotency key "E-03", channel "OfflineMarket" and source reference "OFF-03" is stored on the entry
      And the stored SaleRequest has processedBy "MC-1"
      And SaleRecordingPort records one sale and returns saleRef "S-100"
      And entry "E-03" is Reconciled with saleRef "S-100"
      And stock item "CER-103" is Sold

    Scenario: Reconciling an entry that is already reconciled
      Given entry "E-03" is Reconciled with saleRef "S-100"
      When the market coordinator reconciles entry "E-03" again
      Then the result is OfflineOperationRejected
      And only one sale exists for idempotency key "E-03"

  Rule: Retries recover a sale that was already recorded

    Scenario: Sale is recorded but the response is lost
      Given entry "E-03" for "CER-103" is AwaitingReconciliation
      And SaleRecordingPort records the sale as "S-100" but the response is lost
      When the market coordinator reconciles entry "E-03"
      Then a technical failure "SaleRecordingUnavailable" is reported
      And entry "E-03" is still AwaitingReconciliation
      And the SaleRequest with idempotency key "E-03" remains stored on the entry

    Scenario: Retry recovers the original saleRef without creating another sale
      Given entry "E-03" is AwaitingReconciliation with its stored SaleRequest
      And a sale "S-100" was already recorded for idempotency key "E-03"
      And stock item "CER-103" is now Sold
      When the market coordinator reconciles entry "E-03" again
      Then the stored SaleRequest is reused
      And findRecordedResult returns Recorded with saleRef "S-100"
      And entry "E-03" is Reconciled with saleRef "S-100"
      And entry "E-03" is not referred to the manager
      And only one sale exists for idempotency key "E-03"

    Scenario: A retry by another coordinator keeps the original processedBy
      Given entry "E-03" is AwaitingReconciliation with its stored SaleRequest with processedBy "MC-1"
      And the authorised market coordinator "MC-2" is now signed in
      When the market coordinator reconciles entry "E-03" again
      Then the stored SaleRequest is reused
      And the stored SaleRequest still has processedBy "MC-1"

    Scenario: Recovering the previous sale result fails
      Given entry "E-03" is AwaitingReconciliation with its stored SaleRequest
      And SaleRecordingPort cannot look up previous results
      When the market coordinator reconciles entry "E-03"
      Then a technical failure "SaleRecordingUnavailable" is reported
      And no stock check or sale recording is attempted
      And entry "E-03" is still AwaitingReconciliation

    Scenario: Sale recording times out
      Given entry "E-03" for "CER-103" is AwaitingReconciliation
      And sale recording times out
      When the market coordinator reconciles entry "E-03"
      Then a technical failure "SaleRecordingUnavailable" is reported
      And entry "E-03" is still AwaitingReconciliation
      And the retry will use the same SaleRequest and idempotency key

  Rule: Duplicates, conflicts and rejected sales are referred to the manager

    @SC-13
    Scenario: Refer a duplicate offline reference
      Given entry "E-03" with offline reference "OFF-03" is Reconciled
      When the market coordinator enters submission "SUB-9" with offline reference "OFF-03"
      Then a new entry "E-09" is recorded as ReferredToManager with reason "DuplicateReference"
      And no second sale is recorded

    @SC-14
    Scenario: Refer an offline transaction for an item already sold
      Given entry "E-04" for "CER-105" is AwaitingReconciliation
      When the market coordinator reconciles entry "E-04"
      Then entry "E-04" is ReferredToManager with reason "ItemAlreadySold"
      And SaleRecordingPort.recordSale is not called

    Scenario: Refer an offline transaction for a reserved item
      Given stock item "CER-106" is Reserved
      And entry "E-06" for "CER-106" is AwaitingReconciliation
      When the market coordinator reconciles entry "E-06"
      Then entry "E-06" is ReferredToManager with reason "ItemReserved"
      And no sale is recorded

    Scenario: No line is sold when one line conflicts
      Given entry "E-07" for "CER-103" and "CER-105" is AwaitingReconciliation
      When the market coordinator reconciles entry "E-07"
      Then entry "E-07" is ReferredToManager with reason "ItemAlreadySold"
      And stock item "CER-103" is still Available

    Scenario: Idempotency key conflict is handled as a rejected request
      Given entry "E-08" is AwaitingReconciliation
      And idempotency key "E-08" was already used with a different payload
      When the market coordinator reconciles entry "E-08"
      Then entry "E-08" is ReferredToManager with reason "SaleRejected"
      And the referral detail is "IdempotencyKeyConflict"
      And no sale is recorded

  Rule: The manager resolves referred entries without recording a sale

    @SC-15
    Scenario: Manager resolves a referred offline transaction
      Given entry "E-04" is ReferredToManager
      And the manager "MG-1" is signed in
      When the manager resolves entry "E-04" with decision "Rejected" and note "item already sold in the shop"
      Then entry "E-04" is Resolved with the decision, note and resolvedAt
      And resolvedBy is "MG-1"
      And no sale is recorded from entry "E-04"

    Scenario: Only a manager may resolve a referred entry
      Given entry "E-04" is ReferredToManager
      When the market coordinator tries to resolve entry "E-04"
      Then the result is OfflineOperationRejected with reason "UnauthorisedManager"
      And entry "E-04" is still ReferredToManager
