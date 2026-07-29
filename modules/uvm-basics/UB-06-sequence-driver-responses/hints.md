# UB-06 Hints

## Level 1 — Diagnostic question

What information must the returned object preserve so the sequencer knows which
waiting sequence owns it?

## Level 2 — Invariant

Every accepted request produces exactly one identified response, and the
requesting sequence—not the driver—checks its meaning.

## Level 3 — Location

Response construction belongs after `get_next_item` in the driver. Response
retrieval and validation belong after `finish_item` in the sequence.

## Level 4 — Reduced pseudocode

```text
driver:
  receive request
  create separate response
  preserve routing identity
  fill result
  complete request with response

sequence:
  send request
  receive base response
  recover concrete type
  validate relationship to request
```

## Level 5 — Minimal repair direction

Use the response object's identity-copying method before returning it, then
retrieve the response through the sequence API and explicitly cast it before
dereferencing its fields.

## Level 6 — Reference direction

Compare the response flow in the learning resource with the bare `item_done()`
handshake from UI-G1. Keep the existing test objection boundary unchanged.
