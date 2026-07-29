# UB-06: Coordinate sequences, sequencers, drivers, and tests

## Why this matters

Your UI-G1 driver acknowledged requests with `item_done()`. Some protocols also
return transaction-level results. A sequence that only knows its request was
accepted cannot validate that result.

## Learn first

Read [resources/request-response-flow.md](resources/request-response-flow.md)
before editing the package. It introduces response routing and the difference
between completing a request and receiving its result.

## Observable contract

This module uses a transaction-level service rather than RTL:

- the sequence sends three requests with tags 0, 1, and 2;
- the driver returns exactly one response for each request;
- a response keeps the request tag and has `result == operand + 1`;
- the sequence validates every response;
- the test ends only after all three validations complete.

Exact object names and report wording are not graded.

## Your work

Complete the behavioral TODOs in [tb/ub06_pkg.sv](tb/ub06_pkg.sv). The
transaction, sequencer, component structure, connections, and test lifetime are
supplied. Own the response-producing behavior in the driver and the
response-validating behavior in the sequence.

Run:

```powershell
cd "C:\Learning UVM\modules\uvm-basics\UB-06-sequence-driver-responses"
.\run.ps1
```

The starter intentionally fails until the request/response behavior is
implemented. A passing run reports three verified responses and zero UVM
errors or fatals.

## Constraints

- Keep the three-request contract.
- Return responses through the sequencer response path.
- Do not replace response checking with shared state or a driver-side assertion.
- Expected time: about 120 minutes.

## Prediction

If a driver creates a correct response payload but does not associate it with
the originating request, can the sequencer reliably route it back to the
waiting sequence?

## Completion

Pass the default run, explain the request-completion/response distinction in
[reflection.md](reflection.md), and show that a wrong response would be rejected.
