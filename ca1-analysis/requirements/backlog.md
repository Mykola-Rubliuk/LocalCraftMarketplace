# User Stories and Acceptance Criteria

## US-01 — Reserve an item

**As a** shop volunteer, **I want** to record a reservation for an available item, **so that** it is not offered to another customer while the reservation is active.
**Value:** Avoid conflicting commitments.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-02.
- **Requirements:** FR-04, FR-05.
- **Use case:** UC-02.
- **Rules:** A-01, A-02 (unconfirmed).
- **Gherkin:** SC-01, SC-02, SC-03.
- **Question:** Q-01.

**Acceptance criteria**

- **AC-01:** A reservation for an available item is recorded with customer and agreed conditions.
- **AC-02:** A second conflicting active reservation is rejected.
- **AC-03:** Reservation expiry is applied only according to an approved policy.

## US-02 — Track partial fulfilment

**As a** shop volunteer, **I want** to record readiness and collection for each order line, **so that** a customer can know which parts are ready.
**Value:** Reduce confusion in mixed-maker orders.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-05.
- **Requirements:** FR-06, FR-07.
- **Use case:** UC-04.
- **Rules:** BR-02, BR-03, A-04 (unconfirmed).
- **Gherkin:** SC-04.
- **Question:** Q-03.

**Acceptance criteria**

- **AC-04:** A collected line can be marked collected without marking uncollected lines collected.
- **AC-05:** The order remains incomplete when another line is still being made.

## US-03 — Record commission changes

**As a** manager, **I want** to record proposed changes to commission terms, **so that** agreed specifications are not confused with suggestions.
**Value:** Preserve approval evidence.

- **Priority:** Should (proposed).
- **Stakeholders:** ST-01, ST-04, ST-05.
- **Requirement:** FR-08.
- **Use case:** UC-05.
- **Rules:** A-05 (unconfirmed).
- **Gherkin:** SC-05.
- **Question:** Q-04.

**Acceptance criteria**

- **AC-06:** Proposed price changes do not replace agreed prices until approved under the applicable policy.
- **AC-07:** The recorded commission distinguishes proposed from approved terms.

## US-04 — Record stock movements

**As a** market coordinator, **I want** to record when an item changes location or stock status, **so that** the system reflects where the item is and whether it is available.
**Value:** Maintain accurate stock records.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-03.
- **Requirements:** FR-02, FR-03.
- **Use case:** UC-03.
- **Rules:** A-03 (unconfirmed).
- **Gherkin:** SC-06.
- **Question:** Q-02.

**Acceptance criteria**

- **AC-08:** A stock movement is recorded with the item, movement date, reason and relevant location details.
- **AC-09:** The item's recorded location is updated after a confirmed movement.

## US-05 — Record customer sales

**As a** shop volunteer, **I want** to record customer sales and the items sold, **so that** the cooperative can maintain reliable sales and stock records.
**Value:** Improve sales tracking and support maker reconciliation.

- **Priority:** Must (proposed).
- **Stakeholders:** ST-01, ST-02, ST-04.
- **Requirements:** FR-01, FR-10.
- **Use cases:** UC-01, UC-07.
- **Rules:** BR-01.
- **Gherkin:** SC-07.
- **Question:** Q-06.

**Acceptance criteria**

- **AC-10:** A completed sale records the items sold, quantities and applicable selling prices.
- **AC-11:** A sale is associated with the relevant maker or makers through the recorded products.
- **AC-12:** A completed sale is reflected in the recorded stock information.

## US-06 — Protect maker-payment information

**As a** manager, **I want** access to confidential maker-payment summaries to be restricted by user role, **so that** volunteers can process sales without accessing sensitive financial information.
**Value:** Protect confidential business information.

- **Priority:** Must (proposed).
- **Stakeholders:** ST-01, ST-02.
- **Requirements:** FR-11, NFR-01.
- **Use case:** UC-07.
- **Rules:** BR-04, A-07 (unconfirmed).
- **Gherkin:** SC-08.
- **Question:** Q-07 (role permissions to be confirmed).

**Acceptance criteria**

- **AC-13:** A manager can access the maker-payment summaries permitted by their role.
- **AC-14:** A shop volunteer cannot access confidential maker-payment summaries.
- **AC-15:** Restricting access to payment summaries does not prevent an authorised volunteer from recording a customer sale.

## US-07 — Record customer return requests

**As a** shop volunteer, **I want** to record a customer's return, exchange or repair request, **so that** the issue can be reviewed and its outcome documented.
**Value:** Ensure customer issues are traceable.

- **Priority:** Should (proposed).
- **Stakeholders:** ST-02, ST-05.
- **Requirement:** FR-09.
- **Use cases:** UC-06, UC-09.
- **Rules:** A-06 (unconfirmed).
- **Gherkin:** SC-09.
- **Question:** Q-05.

**Acceptance criteria**

- **AC-16:** A return request records the relevant sale or item, the reason and the date.
- **AC-17:** The request can be referred to the manager for review.
- **AC-18:** The request's outcome is recorded after a decision is made.

## US-08 — Maintain product information

**As a** maker, **I want** to maintain the product information associated with my own items, **so that** customers and staff can access accurate descriptions, materials, dimensions and prices.
**Value:** Keep marketplace product information accurate.

- **Priority:** Should (proposed).
- **Stakeholder:** ST-04.
- **Requirement:** FR-01.
- **Use case:** UC-08.
- **Rules:** A-09 (unconfirmed).
- **Gherkin:** SC-10.
- **Question:** Q-07.

**Acceptance criteria**

- **AC-19:** An authorised maker can update the product records they are permitted to manage.
- **AC-20:** A maker cannot modify another maker's product records without authorisation.
- **AC-21:** Updated product information is available to authorised staff.

## US-09 — Handle market transactions during internet outages

**As a** market coordinator, **I want** to follow a documented procedure for recording sales when internet access is unavailable and to reconcile them afterwards, **so that** market operations can continue and no transaction is left unaccounted for.
**Value:** Reduce disruption caused by unreliable connectivity.

- **Priority:** Must (proposed).
- **Stakeholders:** ST-01, ST-03.
- **Requirements:** NFR-05, FR-13.
- **Use cases:** UC-01, UC-10.
- **Rules:** A-08, A-10 (unconfirmed).
- **Gherkin:** SC-11, SC-12, SC-13, SC-14, SC-15.
- **Questions:** Q-08, Q-09.

**Acceptance criteria**

- **AC-22:** Staff can follow a documented procedure to record sales during an internet outage.
- **AC-23:** Transactions recorded offline can be reconciled with the main system when connectivity returns.
- **AC-24:** Duplicate or conflicting records are identified and referred to the manager for resolution.
- **AC-25:** Each offline transaction records a unique offline reference, its date and the market coordinator who recorded it.
- **AC-26:** The manager's decision on a referred record is recorded with a note, and no offline transaction remains unaccounted for.

## US-10 — Review open commitments

**As a** manager, **I want** an operational view of incomplete orders, reservations and commissions, **so that** I can follow up open items.
**Value:** Support operational follow-up and exception review.

- **Priority:** Should (proposed).
- **Stakeholder:** ST-01.
- **Requirement:** FR-12.
- **Use case:** UC-07.
- **Gherkin:** SC-16.

**Acceptance criteria**

- **AC-27:** The view lists every order with an uncollected line, every active reservation and every commission awaiting approval.
- **AC-28:** Completed or closed records are not listed.
- **AC-29:** Only authorised staff can open the view.
