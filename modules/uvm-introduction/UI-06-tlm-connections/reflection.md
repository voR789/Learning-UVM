# UI-06 Reflection

1. Which endpoint initiates each `put()` or `get()` call, and which endpoint implements or forwards it?
- The producer intiated `put()`, and the consumer intiated the `get()` call. The producer and consumer forwards the calls to the fifo, and in the case of implementation, the audit and fifo channels implement the actual `put()` and `get()`.
2. Why does the FIFO path need both put and get exports?
- The FIFO path eneds both put and get exports because it acts as a buffer between the producer and consumer, and in order to act as the implementation link between them, it needs to be connected to both put and get ports.
3. Why is the audit sink's imp different from the FIFO's export?
- The audit's sink imp was different form the FIFO's export because the audit directly exposed how it implemented put, while the FIFO kept it in an abstracted layer with export.
4. How does the three-party barrier prevent a false pass when one destination never receives the item?
- The three party barrier prevents the false pass by waiting until the three parties are all done with their jobs, before we verify our results.
5. What coupling would return if the producer directly called methods on concrete consumer and audit components?
- The producer would rely on "hard coded" transaction method API's between the consumer and audit, which would ruin it's reusability if we were to swap out any of the pieces.