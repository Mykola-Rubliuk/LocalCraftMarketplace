# Slice 2 — Operation Contract

Line status values: `BeingMade`, `Ready`, `Collected`, `Cancelled`, `Substituted`. A line is closed when its status is `Collected`, `Cancelled` or `Substituted`. Order status values: `Open`, `Completed`. An order is `Open` while at least one of its lines is not closed. It is `Completed` when all its lines are closed; this does not mean that any line was collected.

Expected refusals are returned as result variants; technical failures are errors (D-CA2-02).

Access is checked before UC-04 starts, so no business refusal is defined for an unauthorised user.

## OC-2.1 `viewOrder(orderId)`

Cross-references: UC-04 steps 1–2 and 2a; FR-07.

| Field | Required? | Meaning |
|---|---|---|
| `orderId` | Yes | Identifier of the order to view. |

### Preconditions
- The user is an authorised Shop Volunteer.
- An existing order has at least one order line.

### Success postconditions
- No state is changed.
- The result contains the order status and each line's `lineId` and status.

### Expected business refusals
- `OrderNotFound`: no order exists with the supplied `orderId`.

The result is `Rejected(reason)`. No state is changed.

For `markReady`, `recordCollection` and `recordCustomerDecision`, the Shop Volunteer chooses the line from those returned by `viewOrder`. The interface supplies that `orderId` and `lineId`, so no business refusal is defined for a line that does not belong to the order.

## OC-2.2 `markReady(orderId, lineId)`

Cross-references: UC-04 steps 3–5 and 4a; SC-04; FR-07, BR-02, BR-03; D-CA2-06, D-CA2-14.

| Field | Required? | Meaning |
|---|---|---|
| `orderId` | Yes | Identifier of the order that contains the line. |
| `lineId` | Yes | Identifier of the line that is finished. |

### Preconditions
- The user is an authorised Shop Volunteer.
- The order exists and the line belongs to it.
- The line is `BeingMade`.

### Success postconditions
- The line's `fulfilmentStatus` is changed to `Ready`.
- The line's `lastChangedBy` is set to the Shop Volunteer and `lastChangedAt` to `Clock.now()`.
- The order's `orderStatus` is recalculated and is `Open`, because the line is not closed.
- No other line is changed.
- The result is `Recorded(lineStatus, orderStatus)`.

### Expected business refusals
- `InvalidStatusChange`: the line is not `BeingMade`.

The result is `Rejected(reason)`. No state change is committed.

## OC-2.3 `recordCollection(orderId, lineId)`

Cross-references: UC-04 steps 3–5 and 4a; SC-04; FR-07, BR-02, BR-03; D-CA2-06, D-CA2-14.

| Field | Required? | Meaning |
|---|---|---|
| `orderId` | Yes | Identifier of the order that contains the line. |
| `lineId` | Yes | Identifier of the line that the customer collects. |

### Preconditions
- The user is an authorised Shop Volunteer.
- The order exists and the line belongs to it.
- The line is `Ready`.

### Success postconditions
- The line's `fulfilmentStatus` is changed to `Collected`.
- The line's `lastChangedBy` is set to the Shop Volunteer and `lastChangedAt` to `Clock.now()`.
- The order's `orderStatus` is recalculated: `Completed` if all its lines are closed, otherwise `Open`.
- No other line is changed.
- The result is `Recorded(lineStatus, orderStatus)`.

### Expected business refusals
- `InvalidStatusChange`: the line is not `Ready`.

The result is `Rejected(reason)`. No state change is committed.

## OC-2.4 `recordCustomerDecision(orderId, lineId, decision, decisionReason)`

Cross-references: UC-04 steps 3–5, 4a and 4b; FR-07, BR-02, BR-03; D-CA2-06, D-CA2-14, D-CA2-15.

| Field | Required? | Meaning |
|---|---|---|
| `orderId` | Yes | Identifier of the order that contains the line. |
| `lineId` | Yes | Identifier of the line that the decision applies to. |
| `decision` | Yes | `Cancelled` or `Substituted`. |
| `decisionReason` | Yes | A value from the predefined list shared by both decisions. The list includes `NotGiven`; the other values are not yet agreed. |

The interface offers only `Cancelled` and `Substituted` for `decision`, and only listed values for `decisionReason`. The Shop Volunteer may leave the reason unchosen, which is refused with `ReasonNotSupplied`. Other values cannot be submitted, so no business refusal is defined for them.

The customer approves the decision offstage. The system records the Shop Volunteer's entry and does not verify the approval (D-CA2-14).

### Preconditions
- The user is an authorised Shop Volunteer.
- The order exists and the line belongs to it.
- The line is `BeingMade` or `Ready`.
- `decision` is `Cancelled` or `Substituted`.
- `decisionReason` is supplied and is a value from the predefined list.

### Success postconditions
- The line's `fulfilmentStatus` is changed to the value of `decision`.
- The line's `decisionReason` is recorded.
- The line's `lastChangedBy` is set to the Shop Volunteer and `lastChangedAt` to `Clock.now()`.
- The order's `orderStatus` is recalculated: `Completed` if all its lines are closed, otherwise `Open`.
- No other line is changed.
- The result is `Recorded(lineStatus, orderStatus)`.

### Expected business refusals
- `InvalidStatusChange`: the line is `Collected`, `Cancelled` or `Substituted`.
- `ReasonNotSupplied`: no `decisionReason` is supplied.

The line's status is checked first. If the line is closed, the result is `Rejected(InvalidStatusChange)`, whether or not a `decisionReason` is supplied.

The result is `Rejected(reason)`. No state change is committed, and no `decisionReason` is recorded or replaced.

## Technical failure guarantee
A technical failure must not leave a partial change. The line's `fulfilmentStatus`, `decisionReason`, `lastChangedBy` and `lastChangedAt`, and the order's `orderStatus`, keep their previous values. The system must not return `Recorded` until the change is committed.
