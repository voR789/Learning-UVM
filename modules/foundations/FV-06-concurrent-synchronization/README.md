# FV-06: Concurrent synchronization

## Observable verification problem

Earlier labs placed drive, delay, observation, and checking in one linear task. A reusable environment separates those responsibilities into concurrent processes. Without synchronization, the monitor can sample too early, the scoreboard can wait forever, or the test can finish while transactions remain unchecked.

This lab verifies a registered adder. Inputs are driven before a rising edge. When `in_valid` is high at that edge, the DUT registers `a + b`, asserts `out_valid`, and the monitor observes the result after the edge.

## Predict before coding

If the generator finishes producing items before the scoreboard finishes checking them, which event should control test termination: generation complete or checking complete? Why?

## Your task

Complete `tb/concurrency_lab.sv` so four concurrent processes cooperate:

1. The generator creates `NUM_ITEMS` transactions and sends them to the driver mailbox.
2. The driver waits for reset release, retrieves each transaction, drives before a rising edge, and sends an independent expected transaction to the scoreboard.
3. The passive monitor observes only accepted DUT outputs and sends observations to the scoreboard.
4. The scoreboard blocks until it receives matching expected and actual transactions, checks them, and signals completion after `NUM_ITEMS` comparisons.

Use the supplied mailboxes and events. Do not let the monitor read driver-owned transaction objects or predict from DUT internals.

## Run

```powershell
cd "C:\Learning UVM\modules\foundations\FV-06-concurrent-synchronization"
.\run.ps1 -Seed 1
```

The starter is expected to fail because no transactions are checked.
