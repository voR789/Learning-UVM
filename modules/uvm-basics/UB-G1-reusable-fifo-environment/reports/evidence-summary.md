# UB-G1 evidence summary

Complete after implementation.

- Known-good command and seed: .\run.ps1 -Seed 1
- Known-good completion counts and coverage: Completion count: 22 transactions, 100% coverage.
- Faulty-DUT command and seed: -  .\run.ps1 -Seed 1 -DutPath .\tests\fixtures\invalid_sync_fifo.sv
- First `UBG1_MISMATCH` context:  Observed transaction: rst=0 wr=1 rd=0 wdata=0xff rdata=0x00 full=1 empty=0 count=3, Expected transaction: empty= 0, full= 0, count= 3, rdata= 00
- Short root-cause explanation: Faulty DUT asserts full on DEPTH - 1, not DEPTH.
