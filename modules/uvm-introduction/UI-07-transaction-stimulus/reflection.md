# UI-07 Reflection

1. What does each of the four handshake calls guarantee?
- The four handshake calls `start_item()`, `finish_item()`, `get_next_item()`, and `item_done()` are used to arbitrate handshaking by the sequencer to make sure no item is corrupted. With start and finish item, the sequence communicates to the sequencer to request permission to begin the next item, and waits for the driver's completion before starting again. And for get next item and item done, it's between the sequencer and the driver, communicating ownership to the driver, letting the sequencer know when to send the next sequence item. This tight handshaking arbitrated by the sequencer makes sure sequence items are fully constructed, and fully driven with no overlap.
2. Why are fields assigned after `start_item` but before `finish_item`?
- The fields are assigned after and before these calls because the calls mark the grant and submission for an item. The fields must be assigned between these two actions or else they are not successfully communicated to the driver.
3. What specialized TLM connection joins driver and sequencer?
- The `driver.seq_item_port` connects to the `sequencer.seq_item_export`.
4. Why does missing `item_done` block sequence completion?
-  It sequences completion because it submits the request, and waits for the driver to finish completion. Without it, the sequencer doesn't know that the driver has finished driving a sequence item, so it blocks the acknowledgement that `finish_item()` is waiting for.
5. How would a real driver extend this lab without changing sequence policy?
- A real driver would drive the inputs to the DUT between the handshaking policy of `get_next_item()`, and `item_done()`.
