# Predictor-to-scoreboard flow

## The observable problem

A scoreboard can calculate an expected value inside the same callback that
receives an actual value. That is compact, but it couples the reference model,
observation timing, and comparison into one component. As environments grow,
the expected result may require a reusable model, may arrive on a different
schedule, or may be consumed by more than one checker.

UA-04 separates the responsibilities:

- The source represents observation. It publishes command transactions and
  actual result transactions on independent analysis ports.
- The predictor consumes commands and transforms each one according to the
  specification. It publishes expected results.
- The scoreboard consumes expected and actual results, pairs them, and reports
  agreement or mismatch.

The governing invariant is: **each observed command produces exactly one
expected transaction, and each checked operation consumes exactly one expected
and one actual transaction with matching identity.**

## Why use two analysis FIFOs?

An analysis port calls subscribers immediately, but two independent streams do
not have to arrive in the same callback or delta cycle. A
`uvm_tlm_analysis_fifo` accepts writes through its `analysis_export` and lets a
consumer later call blocking `get()`.

The scoreboard can therefore do this conceptually:

```text
get next expected
get next actual
compare their IDs
compare their values
```

If actual arrives first, it waits in the actual FIFO. If expected arrives first,
it waits in the expected FIFO. This solves arrival-time decoupling; it does not
solve arbitrary reordering. An ordered one-to-one stream can pair by FIFO order.
A genuinely out-of-order protocol needs associative storage keyed by transaction
ID, which is outside this unit.

## Worked example: packet length prediction

Suppose a monitor publishes a packet header and another monitor publishes the
encoded packet length produced by the DUT.

```systemverilog
class length_predictor extends uvm_subscriber #(packet_header);
  uvm_analysis_port #(length_result) expected_ap;

  function void write(packet_header header);
    length_result expected;
    expected = length_result::type_id::create("expected");
    expected.id = header.id;
    expected.bytes = header.payload_words * 4;
    expected_ap.write(expected);
  endfunction
endclass
```

The predictor does not inspect the DUT result. It uses only the observed input
and the specification. The scoreboard later compares this expected object with
the independently observed DUT result.

## UA-04 specification

For each command:

- ADD: expected value is the low eight bits of `a + b`.
- XOR: expected value is `a ^ b`.
- The expected result must retain the command's `id`.
- The predictor publishes one newly created result object per command.

The scoreboard must compare both `id` and `value`. Matching values attached to
different commands are not interchangeable.

## Prediction

The actual result for ID 1 is written before the expected result for ID 1.
Both channels remain ordered and one-to-one. What happens when the scoreboard
blocks on the expected FIFO first, and why does the earlier actual result remain
available afterward?
