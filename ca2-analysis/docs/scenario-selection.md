# Scenario Selection Record

## 1. Selected Scenario

The group selected **Local Craft Marketplace — Kerry Makers Cooperative** for the CA2 Collaborative Object-Oriented Design project.

The group evaluated two candidate scenarios:

1. **Local Craft Marketplace — Kerry Makers Cooperative**
2. **Renewable Energy Maintenance Service**

Both scenarios offered opportunities to analyse business requirements, identify domain objects, model interactions and apply object-oriented design principles.

Following the comparison, the group agreed that Local Craft Marketplace provides the strongest basis for collaborative design, responsibility allocation and integration across the four group members.

## 2. Scenario Overview

### 2.1 Local Craft Marketplace — Kerry Makers Cooperative

The Local Craft Marketplace scenario focuses on a cooperative that sells products created by local makers, including ceramics, textiles, woodwork, prints and jewellery.

The organisation currently relies on spreadsheets, handwritten records, messages and other manual processes to manage products, stock, reservations, customer orders and sales.

The selected system aims to improve the reliability of these records and support several interconnected business processes, including:

- Product and stock record management.
- Item reservations and reservation expiry.
- Multi-maker customer order fulfilment.
- Customer sales and maker attribution.
- Commission and return records.
- Recording and reconciling transactions captured during offline market activities.
- Controlled access to confidential information.

### 2.2 Renewable Energy Maintenance Service

The Renewable Energy Maintenance scenario focuses on the management of maintenance activities within a renewable energy service organisation.

It provides a technical business domain in which equipment, maintenance activities and operational processes can be analysed and represented through object-oriented models.

The scenario offers opportunities to identify domain entities, assign responsibilities, model interactions and define system behaviour associated with maintenance operations.

Although this scenario was considered suitable for object-oriented analysis and design, the group selected Local Craft Marketplace because of its stronger fit with the intended collaborative structure and proposed use cases.

## 3. Comparison Criteria

The scenarios were evaluated against criteria relevant to the CA2 learning outcomes.

| **Criterion** | **Local Craft Marketplace** | **Renewable Energy Maintenance** |
|---|---|---|
| Manageable scope | Medium. Requires limiting the design to selected marketplace processes. | Potentially more focused around maintenance operations, depending on the selected scope. |
| Behavioural richness | High. Includes reservations, sales, order fulfilment and offline reconciliation. | High. Provides opportunities to model equipment-related and maintenance workflows. |
| Domain complexity | Multiple business entities, relationships, roles and transaction rules. | Technical entities and relationships associated with equipment and maintenance activities. |
| Object-oriented design potential | High. Distinct entities, services, policies, repositories and interfaces can be identified. | High. Equipment, maintenance activities and related responsibilities can be modelled. |
| Alternative and exceptional flows | Includes unavailable items, conflicting reservations, partial fulfilment and duplicate offline transactions. | Offers opportunities to model unsuccessful maintenance operations and other operational exceptions. |
| Interaction modelling | Supports interactions between reservations, stock, orders, sales and offline transactions. | Supports interactions between equipment, maintenance activities and operational processes. |
| Responsibility allocation | Supports division into several distinct but interconnected business processes. | Supports division into technical and operational responsibilities. |
| Collaborative integration | Provides opportunities to define shared interfaces and integrate independently designed slices. | Also suitable for collaborative design, depending on the selected use cases. |

## 4. Evaluation of the Candidates

### 4.1 Local Craft Marketplace

The main strength of the Local Craft Marketplace scenario is the variety of interconnected business processes.

Each process has distinct responsibilities and business rules, but changes in one process can affect other parts of the system.

For example:

- Reserving an item changes its availability.
- Recording a sale changes the stock status of the sold item.
- Order fulfilment involves individual order lines that may progress independently.
- Offline transactions must be checked before they can be recorded as confirmed sales.
- Maker attribution must be preserved when recording sales and transaction evidence.

These relationships provide opportunities to demonstrate object-oriented concepts such as encapsulation, responsibility assignment, collaboration between objects, cohesion and coupling.

The scenario also supports meaningful success, alternative, refusal and boundary conditions, which are important when preparing detailed use cases, Gherkin scenarios, system sequence diagrams and operation contracts.

### 4.2 Renewable Energy Maintenance

The Renewable Energy Maintenance scenario offers a more specialised technical domain.

Its main strengths include:

- A focused organisational context.
- Opportunities to model equipment and maintenance-related entities.
- Technical workflows with defined responsibilities.
- Opportunities to represent operational states and interactions.

However, the group determined that Local Craft Marketplace offers a stronger fit for the proposed collaborative structure because it contains several clearly distinguishable business processes with explicit dependencies between them.

Both scenarios provide valid opportunities for object-oriented analysis and design, but Local Craft Marketplace was selected as the more suitable option for this group's CA2 project.

## 5. Final Selection Rationale

The group selected **Local Craft Marketplace — Kerry Makers Cooperative** as the CA2 project scenario.

The decision was based on the following reasons:

1. **Behavioural variety:** The scenario includes several distinct processes, such as reservations, order fulfilment, customer sales and offline transaction reconciliation.
2. **Clear domain responsibilities:** It provides identifiable domain concepts, including Product, StockItem, Reservation, CustomerOrder, OrderLine, Sale, SaleLine, Maker and OfflineTransaction.
3. **Object-oriented design opportunities:** The scenario supports the identification of collaborating classes, services, repositories, policies and shared interfaces.
4. **Interaction complexity:** Changes in one business process can affect other processes, providing useful material for modelling object interactions and defining operation contracts.
5. **Collaborative suitability:** The selected behaviour can be divided into four related slices, allowing each group member to take responsibility for a specific area while contributing to one integrated design.
6. **Manageable design scope:** The group can concentrate on selected business processes without attempting to design a complete public e-commerce platform, online payment system or full accounting solution.

Overall, the group agreed that Local Craft Marketplace provides the strongest fit for its four-slice structure and the intended collaborative object-oriented design work.

## 6. Agreed Behavioural Scope

The group agreed to focus on four interconnected use cases:

| **Slice** | **Use Case** | **Main Behaviour** |
|---|---|---|
| Slice 1 | UC-02 — Manage Reservation | Create reservations, check item availability and evaluate reservation expiry. |
| Slice 2 | UC-04 — Manage Customer Order | Manage order-line progress, collection, substitution and cancellation. |
| Slice 3 | UC-10 — Reconcile Offline Transactions | Record offline transactions, identify duplicates and conflicts, and manage reconciliation outcomes. |
| Slice 4 | UC-01 — Process Customer Sale | Validate items, record sales, preserve maker attribution and update stock availability. |

These use cases establish individual areas of responsibility while requiring shared design decisions concerning stock availability, transaction recording and time-related behaviour.

All four slices contribute to one integrated system design and must remain consistent with the agreed CA1 requirements and business rules.

## 7. Scope Boundaries

To keep the design manageable, the group agreed that the following areas are outside the CA2 design scope:

- A complete public-facing e-commerce platform.
- Online payment gateway integration.
- Full financial accounting and bookkeeping.
- External delivery provider integration.
- Advanced analytics and business intelligence.
- Detailed implementation of third-party services.

The project focuses on the selected marketplace processes and their object-oriented design.

## 8. Approval and Agreement Status

**Status: Approved by the group.**

The group confirmed Local Craft Marketplace — Kerry Makers Cooperative as the selected scenario and agreed on the behavioural scope and CA1 baseline to be used for the CA2 design.

| **Approval Item** | **Status** |
|---|---|
| Candidate scenarios identified | Completed |
| Scenario comparison prepared | Completed |
| Preferred scenario selected | Completed |
| Group confirmation | Completed |
| Agreed CA1 baseline recorded | Completed |
| Four behavioural slices agreed | Completed |

## 9. CA1 Baseline References

The existing CA1 artefacts form the foundation of the selected CA2 scenario.

The group uses these artefacts as references rather than reproducing the entire CA1 report in the CA2 dossier.

Accepted corrections, clarifications and additions are documented in:

- `agreed-baseline.md`
- `baseline-change-log.md`

These documents record the CA1 elements retained for CA2 and the changes agreed by the group.

**Repository references:**

- [Local Craft Marketplace — Kerry Makers Cooperative](https://github.com/Mykola-Rubliuk/LocalCraftMarketplace)
- [Renewable Energy Maintenance Service](https://github.com/BohdanByrdin/RenewableEnergyMaintenance)