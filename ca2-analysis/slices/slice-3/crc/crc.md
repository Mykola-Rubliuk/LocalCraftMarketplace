# CRC cards — Slice 3

## OfflineReconciliationService
| Responsibilities | Collaborators |
|---|---|
| Handle enterOfflineTransaction, reconcile and resolve | OfflineTransactionRepository |
| Check the user's role (Coordinator / Manager) | ConflictChecker |
| Validate form data and refuse incomplete entries | SaleRecordingPort |
| Create OfflineTransaction and OfflineLines | Clock |
| Call SaleRecordingPort only after a clean check | OfflineTransaction |

## OfflineTransaction
| Responsibilities | Collaborators |
|---|---|
| Know entryId, submissionId, offlineRef, date, recordedBy, recordedAt | OfflineLine |
| Know status, referralReason, saleId, decision, note, resolvedBy, resolvedAt | |
| markReconciled(saleId) — only from AwaitingReconciliation | |
| refer(reason) — only from AwaitingReconciliation | |
| resolve(decision, note, by, at) — only from ReferredToManager | |

## OfflineLine
| Responsibilities | Collaborators |
|---|---|
| Know itemCode and offline price | — |

## ConflictChecker
| Responsibilities | Collaborators |
|---|---|
| Detect a repeated offline reference | OfflineTransactionRepository |
| Check every line for sold, reserved or unknown items | StockAvailabilityPort |
| Return clean or a referral reason without side effects | |

## OfflineTransactionRepository (port)
| Responsibilities | Collaborators |
|---|---|
| Save offline transactions | — |
| Find by reference and status, by submissionId | |
| Tell whether another record uses a reference | |
| Count records by status (NFR-05) | |

## StockAvailabilityPort (shared port)
| Responsibilities | Collaborators |
|---|---|
| Report availability of an item code: available, sold, reserved, unknown | — |

## SaleRecordingPort (provided by Slice 4)
| Responsibilities | Collaborators |
|---|---|
| Record an atomic sale with maker attribution | — |
| Mark items sold | |
| Return Recorded(saleId) or Rejected(reason); honour the idempotency key | |

## Clock
| Responsibilities | Collaborators |
|---|---|
| Provide the current date and time | — |