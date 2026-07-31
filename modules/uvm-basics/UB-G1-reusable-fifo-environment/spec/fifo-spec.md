# UB-G1 FIFO contract

This module reuses the externally observable FIFO behavior already established
in `modules/foundations/FV-G1-fifo-integration/spec/fifo-hardware-specification.md`.
That document remains authoritative; this is the bounded gate summary.

- Configuration: `WIDTH=8`, `DEPTH=4`, one rising-edge clock.
- Reset is synchronous active high and has priority over read/write requests.
- Reset produces `count=0`, `empty=1`, `full=0`, and `rdata=0`.
- Acceptance uses independent pre-edge occupancy:
  `wr_en && occupancy_pre < DEPTH` and
  `rd_en && occupancy_pre > 0`.
- An accepted read returns and removes the oldest stored value.
- An accepted write appends `wdata` after all unread values.
- Simultaneous requests use independent acceptance; there is no boundary bypass.
- Rejected operations do not change contents, occupancy, or retained `rdata`.
- After the edge settles, `count` equals occupancy, `empty` iff count is zero,
  and `full` iff count equals depth.
- Ordering must survive blocked requests, simultaneous operations, and pointer
  wraparound.

The scoreboard must derive all expectations from passive request observations
and independent model state. DUT status outputs are comparison targets, never
prediction inputs.
