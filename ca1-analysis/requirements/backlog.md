# User Stories and Acceptance Criteria

## US-01 — Reserve an item
**As a** shop volunteer, **I want** to record a reservation for an available item, **so that** it is not offered to another customer while the reservation is active.  
**Value:** Avoid conflicting commitments. 

* **Priority:** Must (proposed). 
* **Stakeholder:** ST-02. 
* **Requirements:** FR-04, FR-05. 
* **Use case:** UC-02. 
* **Rules:** BR-04, A-01/A-02 (unconfirmed). 
* **Gherkin:** SC-01, SC-02, SC-03.
- **AC-01:** A reservation for an available item is recorded with customer and agreed conditions.
- **AC-02:** A second conflicting active reservation is rejected.
- **AC-03:** Reservation expiry is applied only according to an approved policy.
- **Question:** Q-01.

## US-02 — Track partial fulfilment
**As a** shop volunteer, **I want** to record readiness and collection for each order line, **so that** a customer can know which parts are ready.  
**Value:** Reduce confusion in mixed-maker orders. 

* **Priority:** Must (proposed). 
* **Stakeholder:** ST-05. 
* **Requirements:** FR-06, FR-07. 
* **Use case:** UC-04. 
* **Gherkin:** SC-04.
- **AC-04:** A collected line can be marked collected without marking uncollected lines collected.
- **AC-05:** The order remains incomplete when another line is still being made.
- **Question:** Q-03.

## US-03 — Record commission changes
**As a** manager, **I want** to record proposed changes to commission terms, **so that** agreed specifications are not confused with suggestions.  
**Value:** Preserve approval evidence. 

* **Priority:** Should (proposed). 
* **Stakeholder:** ST-01/ST-04/ST-05. 
* **Requirement:** FR-08. 
* **Use case:** UC-05. 
* **Gherkin:** SC-05.
- **AC-06:** Proposed price changes do not replace agreed prices until approved under the applicable policy.
- **AC-07:** The recorded commission distinguishes proposed from approved terms.
- **Question:** Q-04.

## US-04 — Record stock movements

**As a** market coordinator, **I want** to record when an item changes location or stock status, **so that** the system reflects where the item is and whether it is available.  
**Value:** Maintain accurate stock records.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-03.
- **Requirements:** FR-02, FR-03.
- **Use case:** UC-03.
- **Gherkin:** SC-06.

* **AC-08:** A stock movement is recorded with the item, movement date, reason and relevant location details.
* **AC-09:** The item's recorded location is updated after a confirmed movement.
* **AC-10:** An item that is reserved or temporarily unavailable is not presented as available for a new reservation.
* **Question:** Q-03.

## US-05 — Record customer sales

**As a** shop volunteer, **I want** to record customer sales and the items sold, **so that** the cooperative can maintain reliable sales and stock records.  
**Value:** Improve sales tracking and support maker reconciliation.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-02.
- **Requirements:** FR-01, FR-09.
- **Use case:** UC-01.
- **Gherkin:** SC-07.

* **AC-11:** A completed sale records the items sold, quantities and applicable selling prices.
* **AC-12:** A sale is associated with the relevant maker or makers through the recorded products.
* **AC-13:** A completed sale is reflected in the recorded stock information.
* **Question:** Q-06.

## US-06 — Protect maker-payment information

**As a** manager, **I want** access to confidential maker-payment summaries to be restricted by user role, **so that** volunteers can process sales without accessing sensitive financial information.  
**Value:** Protect confidential business information.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-01/ST-02.
- **Requirement:** NFR-01.
- **Use case:** UC-07.
- **Gherkin:** SC-08.

* **AC-14:** A manager can access the maker-payment summaries permitted by their role.
* **AC-15:** A shop volunteer cannot access confidential maker-payment summaries.
* **AC-16:** Restricting access to payment summaries does not prevent an authorised volunteer from recording a customer sale.
* **Question:** Role permissions to be confirmed.

## US-07 — Record customer return requests

**As a** shop volunteer, **I want** to record a customer's return, exchange or repair request, **so that** the issue can be reviewed and its outcome documented.  
**Value:** Ensure customer issues are traceable.

- **Priority:** Should (proposed).
- **Stakeholder:** ST-02/ST-05.
- **Requirements:** FR-10.
- **Use cases:** UC-06, UC-09.
- **Gherkin:** SC-09.

* **AC-17:** A return request records the relevant sale or item, the reason and the date.
* **AC-18:** The request can be referred to the manager for review.
* **AC-19:** The request's outcome is recorded after a decision is made.
* **Question:** Q5

## US-08 — Maintain product information

**As a** maker, **I want** to maintain the product information associated with my own items, **so that** customers and staff can access accurate descriptions, materials, dimensions and prices.  
**Value:** Keep marketplace product information accurate.

- **Priority:** Should (proposed).
- **Stakeholder:** ST-04.
- **Requirement:** FR-01.
- **Use case:** UC-08.
- **Gherkin:** SC-10.

* **AC-20:** An authorised maker can update the product records they are permitted to manage.
* **AC-21:** A maker cannot modify another maker's product records without authorisation.
* **AC-22:** Updated product information is available to authorised staff.
* **Question:** Q-07.

## US-09 — Handle market transactions during internet outages

**As a** market coordinator, **I want** to follow a documented procedure for recording transactions when internet access is unavailable, **so that** market operations can continue and records can be reconciled later.  
**Value:** Reduce disruption caused by unreliable connectivity.

- **Priority:** Must (proposed).
- **Stakeholder:** ST-03/ST-01.
- **Requirements:** NFR-05.
- **Use cases:** UC-01, UC-03.
- **Gherkin:** SC-11.

* **AC-23:** Staff can follow a documented procedure to record transactions during an internet outage.
* **AC-24:** Transactions recorded offline can be reconciled with the main system when connectivity returns.
* **AC-25:** Duplicate or conflicting records are identified and referred for resolution.
* **Question:** Q-08.