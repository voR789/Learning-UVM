# UA-04 reflection

Answer concisely after the learner run and fault fixture.

1. Why should the predictor use command observations rather than the driver's
   response object or the DUT's actual result?

- The predictor should use command observations because the DUT may be wrong, so we need a completely independent model run on the same inputs.

2. What timing difference do the two analysis FIFOs tolerate, and what ordering
   problem do they not solve?

- The two analysis FIFOs tolerate latency from the predictor, or output latency of the DUT; they allow the processes to be lined up based on input transactions. They do not fix ordering from designs that put results out of order. Those must be linked via ID.

3. Why must the scoreboard compare transaction identity as well as value?

- It does this so we can verify that the transactions came from the same input, and we are not misaligned in the FIFO.

4. Which command reproduces the corrupt-actual failure, and which component
   reports it?

- .\tests\run-fixture.ps1 -Test ua04_corrupt_actual_test reproduces the failure, and the scoreboard reports it.
