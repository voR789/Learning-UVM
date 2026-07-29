# Request/response flow

## Problem

`item_done()` tells a sequence that the driver has finished with its request.
That alone does not return a result for the sequence to inspect.

## Mental model

Think of the sequencer as managing two related paths:

```text
sequence -- request --> driver
sequence <-- response -- driver
```

The driver receives a request with `get_next_item(req)`. When a result is
needed, it creates a separate response object, copies the request's sequence and
transaction identity with `rsp.set_id_info(req)`, fills the result fields, and
completes the request with `item_done(rsp)`. The sequence later retrieves that
object with `get_response`.

Request completion means the driver has released the request handshake.
Response validation means the sequence has received and checked the returned
result. They are related, but they are not the same event.

## Worked example

Suppose a checksum service receives a transaction containing `block_id` and
bytes. The driver computes a checksum, creates a response, preserves the
request identity, and returns `block_id` plus the checksum. The sequence waits
for the response and compares both fields with its expected values. The test
keeps its objection raised until the sequence finishes checking.

When an API returns the response through a base `uvm_sequence_item` handle, use
`$cast` to recover the concrete transaction type and fail clearly if the type is
wrong.

## Invariant

Every accepted request produces exactly one correctly identified response, and
the test cannot end before the requesting sequence validates it.

## Prediction

If the driver calls bare `item_done()` while the sequence waits in
`get_response`, which side can make further progress?
