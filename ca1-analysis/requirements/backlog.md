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
