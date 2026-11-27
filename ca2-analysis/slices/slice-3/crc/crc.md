# CRC cards — Slice 3

## OfflineReconciliationService (controller)
| Responsibilities | Collaborators |
|---|---|
| Handle `enterOfflineTransaction`, `reconcile(entryId)` and `resolve(entryId, decision, note)` | OfflineTransactionRepository |
| Check the caller's role (`requireCoordinatorRole`, `requireManagerRole`) | OfflineTransaction |
| Validate offline form data and refuse invalid entries | ConflictChecker |
| Create OfflineTransaction and its OfflineLines | SaleRecordingPort |
| Create the SaleRequest once, persist it on the entry before the first sale attempt and reuse it on every retry | Clock |
| Coordinate sale recovery: call `findRecordedResult` before any conflict check | |
| Call `recordSale` only after a clean check | |
| Handle reconciliation results: `Recorded` → Reconciled; `Rejected` (incl. `IdempotencyKeyConflict`) → referred; technical failure → no state change | |
| Return `OfflineOperationResult` | |
| Obtain the signed-in user's ID for `recordedBy`, `resolvedBy` and the `processedBy` of a new SaleRequest; never replace it in a stored request | CurrentUser |

## OfflineTransaction (entity)
| Responsibilities | Collaborators |
|---|---|
| Know `entryId`, `submissionId`, `offlineRef`, `saleDate`, `recordedAt` | OfflineLine |
| Know `recordedBy` — the coordinator who entered the form | SaleRequest |
| Know `status` and `referralReason` | |
| Know `referralDetail` — the underlying reason, e.g. the sale rejection reason | |
| Know `saleRef` — the reference of the recorded sale | |
| Know `saleRequest` — the stable request reused on retries | |
| Know `decision`, `resolutionNote`, `resolvedBy`, `resolvedAt` — the Manager's resolution | |
| `create(...)` — build a new entry in `AwaitingReconciliation` | |
| `markReconciled(saleRef)` — only from `AwaitingReconciliation` | |
| `refer(reason, detail)` — only from `AwaitingReconciliation` (or on entry for a duplicate) | |
| `resolve(decision, note, resolvedBy, resolvedAt)` — only from `ReferredToManager` | |

## OfflineLine (entity)
| Responsibilities | Collaborators |
|---|---|
| Know `itemCode`, `quantity` and `soldPrice` as written on the offline form | — |

## ConflictChecker (domain service)
| Responsibilities | Collaborators |
|---|---|
| `check(transaction)` — detect a repeated `offlineRef` and check every line's stock status | OfflineTransactionRepository |
| Map `Sold` → `ItemAlreadySold`, `Reserved` → `ItemReserved`, `Unknown` → `ItemUnknown` | StockAvailabilityPort |
| Return a `ReferralReason` or nothing, without side effects | |

## OfflineTransactionRepository (repository)
| Responsibilities | Collaborators |
|---|---|
| `findByEntryId(entryId)` — retrieve a unique offline entry | OfflineTransaction |
| `findBySubmissionId(submissionId)` — retrieve an existing submission to prevent duplicate entry | |
| `existsOtherWithRef(offlineRef, entryId)` — detect duplicate offline references | |
| `save(transaction)` — persist an entry and its state changes | |
| `countByStatus(status)` — show what is still awaiting or referred (NFR-05) | |

## StockAvailabilityPort (shared port)
| Responsibilities | Collaborators |
|---|---|
| `getStatus(itemCode)` — report `Available`, `Reserved`, `Sold` or `Unknown`. Slice 3 uses it read-only | — |

## SaleRecordingPort (provided by Slice 4)
| Responsibilities | Collaborators |
|---|---|
| `recordSale(request)` — record one atomic sale, mark items Sold, return `Recorded(saleRef)` or `Rejected(reason)` | SaleRequest |
| `findRecordedResult(request)` — retrieve a previously committed sale result: same key and payload → `Recorded(saleRef)`; same key, different payload → `Rejected(IdempotencyKeyConflict)`; none → null | |

## Clock (shared port)
| Responsibilities | Collaborators |
|---|---|
| `now()` — provide the current date and time for `recordedAt`, `resolvedAt` and the "date not in the future" check | — |

## CurrentUser (shared)
| Responsibilities | Collaborators |
|---|---|
| `getUserId()` — provide the signed-in user's ID; identity only, not role checks | — |
