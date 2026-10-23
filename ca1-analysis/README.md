# Local Craft Marketplace Service

## Project Overview

This project analyses the requirements for a Local Craft Marketplace Service for the Kerry Makers Cooperative. The system aims to improve product and stock tracking, customer reservations, order fulfilment, commission management and sales record keeping.

The project focuses on requirements analysis and conceptual modelling rather than implementing a complete operational system.

## Project Scope

The proposed system covers:

- Product and stock item records.
- Stock movements and availability.
- Customer reservations.
- Customer orders and partial fulfilment.
- Commission specifications and change approval.
- Sales records and maker-attributable evidence.
- Return requests and their review.
- Role-based access to confidential maker-payment information.
- Recording market transactions during internet outages and reconciling them afterwards.

Public e-commerce and online payment processing are outside the current scope.

## Repository Structure

```text
ca1-analysis
├── README.md
├── report/
│   ├── analysis_dossier.md
├── requirements/
│   ├── user-stories.md
│   └── traceability.csv
├── features/
│   └── marketplace.feature
└── diagrams/
    ├── use-case-model.puml
    └── domain-model.puml
```

## Main Artefacts

- **Requirements report:** Documents the scenario interpretation, project scope, stakeholders, functional and non-functional requirements, business rules, analysis and reflection.
- **User stories:** Describe stakeholder needs and expected value.
- **Gherkin scenarios:** Specify observable system behaviour using Given, When and Then.
- **Use-case model:** Illustrates interactions between system actors and use cases.
- **Domain model:** Defines the main domain concepts and their relationships.
- **Traceability matrix:** Links evidence, requirements and expected behaviour.
- **Decision Log:** Records proposed design decisions, their rationale and unresolved questions.

## Design Assumptions

Some design decisions remain provisional because the original scenario does not define every operational policy. These include reservation expiry, direct Maker access, commission change approval and the handling of offline transactions.

Proposed decisions and unresolved questions are documented in the project report and Decision Log.

## Tools and Formats

- Markdown (`.md`) for documentation.
- PlantUML (`.puml`) for UML diagrams.
- Gherkin (`.feature`) for acceptance scenarios.
- CSV (`.csv`) for requirements traceability.
- Git for version control.

## Project Status

The project is currently focused on requirements analysis, acceptance criteria, traceability and conceptual modelling. The documented models and rules are proposed designs and may require confirmation from stakeholders.