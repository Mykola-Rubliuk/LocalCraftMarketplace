# `UC-04` Fulfil Order Lines

| Field | Value |
|---|---|
| **Primary actor** | Shop Volunteer |
| **Offstage stakeholders** | Customer (approves changes, collects order); Maker (finishes the product item); Manager (reads order status through `UC-07`). |
| **Goal** | Record a fulfilment status and customer decision for each order line and retain an accurate record of the progress for each part of the order. |
| **Trigger** | A line is finished, a customer collects it, or a customer agrees to substitute or cancel it. |
| **Preconditions** | Shop Volunteer is authorised; the order exists and has at least one order line. |
| **Minimal guarantee** | No `OrderLine` or `CustomerOrder` status is changed, no `decisionReason` is recorded, and the record of who/when made the last change stays unchanged.|
| **Success guarantee** | The selected line has its new status and, for a customer decision, its `decisionReason` is recorded and who/when made the last change; all other lines are unchanged; the order status reflects its lines.|
| **Related** | `US-02` ; `FR-06` / `Q-SH-11`, `FR-07` / `Q-SH-10`; `BR-02`, `BR-03`; `SC-04`; `D-CA2-06`, `A-04` / `Q-03` / `D-CA2-14`, `D-CA2-15`|

## Main success flow
1. Shop Volunteer identifies the order that contains the line to update.  
2. The system confirms that the order exists and shows each line with its status, along with the overall order status.  
3. Shop Volunteer marks the line `Ready` or `Collected`, or records a customer decision (`Substituted` or `Cancelled`) with its reason.  
4. The system confirms that the change is allowed from the line's current status and, for a customer decision, that a reason is supplied. (see allowed transitions)
5. The system records the new line status (and, for a customer decision, its reason) with who/when made the change and recalculates the order status; if all order lines are closed, the order becomes `Completed`.

Line considered closed, when its status is `Collected`, `Cancelled` or `Substituted`. An order with status `Completed` only means it has no open lines; it does not mean that any line was collected.

**Allowed transitions:**
- `BeingMade` -> `Ready`
- `BeingMade` -> `Cancelled`
- `BeingMade` -> `Substituted`
- `Ready` -> `Collected`
- `Ready` -> `Cancelled`
- `Ready` -> `Substituted`

## Extensions

| Step | Condition | Type | System response | Outcome |
|---|---|---|---|---|
| **4a**  | Status change is not allowed from the line's current status | Refusal  | The system refuses the request and tells the Shop Volunteer that the change is not allowed  | `Rejected(InvalidStatusChange)`; no status changed and no `decisionReason` recorded |
| **4b**  | Customer decision recorded without a reason | Refusal  | The system refuses the request and tells the Shop Volunteer that a reason is required  | `Rejected(ReasonNotSupplied)`; no status changed and no `decisionReason` recorded |

