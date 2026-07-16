# FV-06 Reflection

Complete these in your own words after the normal and fault runs.

1. Why does the driver wait for `reset_done`, and what could happen without that synchronization?
- The driver waits for `reset_done` because it must explicitly wait for the DUT to finish reset. Otherwise, transactions will be ignored while the DUT is in reset, which also clears its outputs.
2. Why does the monitor create fresh observation objects instead of reading driver transactions?
- The monitor creates fresh observation objects to retrieve the actual sum from the DUT. Driver transactions contain the input values and predicted expected sum. The monitor needs to keep the expected and observed transactions separate from one another.
3. What makes mailbox `get()` useful for concurrent processes, and what deadlock can it create?
- Mailbox `get()` is useful for concurrent processes because it lets a process block until another process provides data, avoiding the need to poll. However, when configured incorrectly, `get()` can deadlock a process because it will wait forever. One example is a cyclical deadlock in which one component waits for a second component while that second component waits for the first.
4. Why must `checking_done`, rather than generator completion, control the successful end of the test?
- The `checking_done` event is used because generator completion does not indicate that the remaining concurrent processes have finished. `checking_done` is assigned to the last process in the chain, the scoreboard, so successful completion is gated by all required checks.
