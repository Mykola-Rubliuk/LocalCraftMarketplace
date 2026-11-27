# Slice 2 - CRC Cards

> Draft: these cards cover `viewOrder`, `markReady`, `recordCollection` and `recordCustomerDecision` (UC-04 steps 1–5, 2a, 4a and 4b). The Shop Volunteer's identity comes from `CurrentUser` (D-CA2-20).

## OrderFulfilmentService

| Responsibilities | Collaborators |
|---|---|
| Handle a request to view an order | `CustomerOrderRepository`, `CustomerOrder` |
| Return the order details or `OrderNotFound` | `CustomerOrderRepository` |
| Coordinate marking a line ready and return `Recorded(lineStatus, orderStatus)` or `Rejected(InvalidStatusChange)` | `CustomerOrderRepository`, `CustomerOrder`, `Clock`, `CurrentUser` |
| Coordinate marking a line collected and return `Recorded(lineStatus, orderStatus)` or `Rejected(InvalidStatusChange)` | `CustomerOrderRepository`, `CustomerOrder`, `Clock`, `CurrentUser` |
| Coordinate recording a customer decision, passing the reason on even if missing, and return `Recorded(lineStatus, orderStatus)`, `Rejected(InvalidStatusChange)` or `Rejected(ReasonNotSupplied)` | `CustomerOrderRepository`, `CustomerOrder`, `Clock`, `CurrentUser` |

## CustomerOrderRepository

| Responsibilities | Collaborators |
|---|---|
| Find an order, with its lines, by `orderId` | `CustomerOrder`, `OrderLine` |
| Save an order and its changed line together | `CustomerOrder`, `OrderLine` |

## CustomerOrder

| Responsibilities | Collaborators |
|---|---|
| Know its ID, status and lines | |
| Report each line's ID and status | `OrderLine` |
| Mark one of its lines ready | `OrderLine` |
| Mark one of its lines collected | `OrderLine` |
| Record a customer decision on one of its lines | `OrderLine` |
| Recalculate its order status after an accepted line change | `OrderLine` |

## OrderLine

| Responsibilities | Collaborators |
|---|---|
| Know its `lineId`, fulfilment status, and who made the last change and when, and its `decisionReason` if it has one | |
| Mark itself `Ready` if it is `BeingMade`, recording who made the change and when; otherwise refuse with `InvalidStatusChange` | |
| Mark itself `Collected` if it is `Ready`, recording who made the change and when; otherwise refuse with `InvalidStatusChange` | |
| Apply a customer decision (`Cancelled` or `Substituted`) if it is not closed and a reason is supplied, recording the reason, who made the change and when; otherwise refuse, checking for `InvalidStatusChange` before `ReasonNotSupplied` | |
| Report whether it is closed | |

## Clock (shared)

| Responsibilities | Collaborators |
|---|---|
| Provide the current date and time | |

## CurrentUser (shared)

| Responsibilities | Collaborators |
|---|---|
| Provide the signed-in user's identity | |
