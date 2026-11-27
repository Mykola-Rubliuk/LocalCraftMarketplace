## Bohdan Byrdin — Slice 3 (UC-10 Reconcile Offline Transactions)

| Field | Entry |
|---|---|
| **AI tool** | Claude (Anthropic), Claude.ai chat |
| **What AI was used for** | Clarifying the Slice 3 requirements and the expected CA2 design artefacts; generating draft versions of the slice artefacts (use case, Gherkin, SSD, operation contracts, CRC, GRASP, sequence diagram, README) for me to review and adapt; suggesting decision-log and open-question entries; guidance on Git branches, commits, pull requests and the project board; aligning the slice with the integrated design class diagram after the integration review |
| **Prompts / requests** | 1. Shared the Slice 3 plan (UC-10, linked stories and requirements, draft `reconcile` contract, ports and fakes, test plan) and asked how the slice should be approached. 2. Shared the Issue #3 task list and asked for a draft design addressing each task (scope, duplicates, retry/timeout, conflict handling, SaleRecordingPort interaction, consistency with stock and sale contracts, UML). 3. Asked for the draft to be split into Markdown and PlantUML content that could be placed in the repository. 4. Asked how to track progress on the GitHub project board and how to organise the work into several commits. 5. Shared the Slice 4 folder structure and asked for the Slice 3 artefacts to be reorganised to follow the same structure. 6. Shared the integration change list for Slice 3 and asked for the artefacts to be updated to match the integrated design class diagram (entryId-based operations, SaleRequest fields, sale recovery with `findRecordedResult`, new Gherkin scenarios). |
| **Files affected** | `slices/slice-3/README.md`, `use-case.md`, `features/offline-reconciliation.feature`, `ssd/ssd.puml`, `contracts/operation-contracts.md`, `crc/crc.md`, `grasp/grasp.md`, `sequence/sequence.puml`; rows in `decisions/decision-log.md`, `decisions/open-questions.md`; PB-06 in `backlog/product-backlog.md` |
| **Review, verification and changes** | Checked identifiers and terms against `docs/glossary.md`, the CA1 dossier (UC-10, SC-11–SC-15), `design/integrated-design-class-diagram.puml` and `design/operation-error-catalogue.md`; rendered the PlantUML files in IntelliJ; removed the separate class diagram in favour of the integrated diagram; committed the work in separate commits;|
| **Human decisions** | Adopted the Slice 4 folder structure; accepted entryId-based selection and Manager resolution without a sale as agreed in the integration review |

## Marian Andrei Rogojina ##
**AI TOOL:** ChatGPT

- I have used ChatGPT to expand on the points I was making because my writing would have been too vague to give proper insight on my slice work.
- The prompts used were to expand my writing for more detail, and to pinpoint what documents I need to modify such as "Do I need to update reserve.puml" or "Would customerRef make up for an userId" 
- The artefact affected was the Slice 1 documentary. 
- I have reviewed the AI-Generated content by checking what I was asked to do, seeing if the AI was accurate, and what was not, I have modified it accordingly to properly do what I need to do while understanding the changes I am making.
