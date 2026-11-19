# Product Goal

Enable authorised Kerry Makers Cooperative staff to maintain accurate records of products and stock availability, reservations, multi-maker order fulfilment and sales, including the controlled reconciliation of market transactions captured while offline.

The intended value is to reduce conflicting commitments, improve visibility of customer order progress, provide reliable transaction evidence for makers and ensure that confidential information is accessible only to authorised users.

## Design boundary

The CA2 design focuses on the selected marketplace workflows and the contracts they share. It does not aim to design a complete public e-commerce platform, online payment gateway, full accounting system or automatic offline synchronisation client.

The offline workflow covered by Slice 3 is a manual process: a coordinator enters information from completed offline forms after connectivity returns. The manual form itself is outside the system boundary.

## Shared design principles

- Stock availability has one shared contract used by reservation, sale and offline reconciliation.
- Only Slice 4 records a Sale. Other slices must use `SaleRecordingPort` rather than create Sale or SaleLine records themselves.
- A sale request is all-or-nothing.
- Maker attribution is retained on each sale line.
- Expected business refusals are explicit results; technical failures must not be mistaken for business refusals.
- Open business rules remain open until confirmed by the group or stakeholder.
