# UB-G1 reflection

Answer concisely in your own words after the executable checks pass.

1. Why may a driver response guide the next request but not prove FIFO correctness?

- A driver response may guide the next request, but it doesn't explicitly check all relevant fields of the transaction, like the scoreboard does. It serves as a system to guide the stimulus.

2. Which information does the passive monitor publish, and why is driver intent insufficient?

- The passive monitor publishes the transaction data from the DUT, and the driver intent is insufficient because first, we need to know the signals that were actually pushed to the DUT, as the driver is not guarunteed to be correct, and second, we need the outputs.

3. How does the scoreboard decide read/write acceptance at empty and full boundaries?

- The scoreboard/model decideds read/write acceptance by using if the model's occupancy is not on the edge. It does not use count because the read/write acceptance of the model should be bound entirely upon the model itself.

4. What prevents an adaptive fill or drain loop from hanging forever?

- The explicit count check prevents an infinite hang of the response-request loop for the fill to full and drain to emtpy.

5. Which command and seed reproduce the faulty-DUT mismatch?

- The command .\run.ps1 -Seed 1 -DutPath .\tests\fixtures\invalid_sync_fifo.sv reporduces the faulty-DUT.
