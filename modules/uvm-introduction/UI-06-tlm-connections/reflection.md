# UI-06 Reflection

1. Which endpoint initiates each `put()` or `get()` call, and which endpoint implements or forwards it?
2. Why does the FIFO path need both put and get exports?
3. Why is the audit sink's imp different from the FIFO's export?
4. How does the three-party barrier prevent a false pass when one destination never receives the item?
5. What coupling would return if the producer directly called methods on concrete consumer and audit components?
