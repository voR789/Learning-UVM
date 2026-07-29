# UB-04 Reflection

Answer briefly after both modes pass:

1. Why must the monitor survive passive reuse?

- The monitor survives passive reuse because we may still want to observe the transactions in order to broadcast it to our scoreboard and coverage.

2. What prevents `connect_phase` from dereferencing absent passive-mode handles?

- The conditional statement based on `get_is_active()` stops the program from derefencing an empty driver handle at runtime.

3. Which two tests and seed reproduce your result?

- The active and passive test with seed 1 prove my result.
