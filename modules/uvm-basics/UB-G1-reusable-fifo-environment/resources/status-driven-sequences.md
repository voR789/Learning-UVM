# Status-driven sequences without self-checking

## Observable problem

A fixed sequence can issue exactly four writes because this exercise happens to
use a depth-four FIFO. That does not transfer well to another configuration.
A reusable sequence can instead issue bounded writes until a response reports
that the FIFO reached full, then choose its recovery action.

## Mental model

The response and the scoreboard answer different questions:

| Path                          | Question                                                       |
| ----------------------------- | -------------------------------------------------------------- |
| Driver response to sequence   | What did the interface report, and what should I try next?     |
| Passive monitor to scoreboard | Was the reported DUT behavior correct under the specification? |

The sequence is allowed to react to observed status. It is not allowed to turn
that status into expected status. Otherwise an early or late `full` assertion
could guide the sequence and simultaneously be accepted as correct.

Each adaptive loop must also be bounded. A broken DUT might never assert `full`
or `empty`; the sequence must report a failure rather than run forever.

## Worked example

For an unrelated credit-based transmitter, a driver returns the observed credit
count after each send. A sequence stops sending when the response reports zero
credits. Independently, a passive checker predicts credits from accepted sends
and returns, then compares the observed count. The response controls stimulus;
the checker decides correctness.

## Invariant

Response feedback may choose the next request, but expected behavior comes from
passive observations plus independent model state. Every adaptive loop has a
finite guard.

## Prediction

If the FIFO incorrectly asserts `full` after only three accepted writes, what
will the response-driven sequence do, and which component must identify the
actual defect?
