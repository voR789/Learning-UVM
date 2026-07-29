# UB-06 Reflection

Write concise answers in your own words.

1. What does `item_done()` establish, and what additional fact does
   `get_response()` establish?

- The `item_done()` function establishes the end of the handshake between the driver and sequencer, letting the sequencer know "hey, we are done with this request, you can move on to the next one". The `get_response()` function queries a special response object that the driver can return to the sequencer.

2. Why must the response retain the request's sequence/transaction identity?

- The response must retain the request's identity in order to align it with the request from which it produced from.

3. Which component detects a wrong result, and why is that ownership useful?

- In this case, the result is the response, and the component that detects that is the sequence. This is useful because we may want to send different sequences based on responses by the DUT, so direct ownership there is very useful.

4. What prevents the test from ending before all responses are checked?

- The blocking `get_response()` function stops the sequence from ending early, and because the sequence won't end, `start()` blocks the test level from ending.
