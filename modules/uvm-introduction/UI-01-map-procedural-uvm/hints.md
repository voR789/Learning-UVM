# UI-01 Progressive hints

## Level 1 — Diagnostic question

For the selected FV-G1 row, is it short-lived transaction intent or a role that must persist throughout simulation?

## Level 2 — Concept

UVM objects describe transaction data or stimulus behavior. UVM components provide persistent hierarchy and lifecycle roles.

## Level 3 — Location

Compare the responsibility list in `reading/uvm-mental-model.md` with the matching FV-G1 task or data type named in the worksheet.

## Level 4 — Pseudocode

```text
FV-G1 responsibility
  -> identify data, active timing, passive observation, prediction, or checking
  -> choose the UVM role with the same ownership
  -> explain what bug or coupling the boundary prevents
```

## Level 5 — Minimal repair direction

Ask for review of one attempted mapping row. Correct only the ownership misconception in that row.

## Level 6 — Reference answer

Available only after an explicit request and an explained attempt. Do not replace the learner-owned worksheet wholesale.
