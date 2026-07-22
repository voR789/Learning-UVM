# UVM mental model: structure around verification reasoning

## 1. The problem UVM addresses

A procedural SystemVerilog testbench can verify a block well. FV-G1 proved
that. As environments grow, however, every project can invent different rules
for constructing components, passing configuration, moving transactions,
starting tests, ending tests, and replacing behavior.

UVM standardizes those rules. It does **not** know the DUT specification and it
does not automatically create a correct predictor, useful stimulus, or honest
coverage model.

## 2. Two kinds of things

### Objects

Objects are short-lived data or behavior descriptions. The first important UVM
objects are:

- **sequence item:** one transaction's intent or observed data;
- **sequence:** a procedure that creates and orders sequence items.

They are not permanent nodes in the testbench hierarchy.

### Components

Components are persistent structural roles with a parent and lifecycle. Common
roles include:

- **test:** selects configuration and scenario intent;
- **environment:** contains and connects reusable verification structure;
- **agent:** groups protocol-specific sequencer, driver, and monitor roles;
- **sequencer:** coordinates sequence items offered to a driver;
- **driver:** converts transaction intent into timed pin activity;
- **monitor:** passively converts pin activity into observed transactions;
- **predictor/reference model:** derives expected behavior from the specification;
- **scoreboard:** compares expected and observed results;
- **coverage subscriber:** samples completed observations for scenario coverage.

Do not memorize every class name today. First preserve the ownership boundaries.

## 3. Familiar transaction flow

```text
test selects scenario
        |
sequence creates request items
        |
sequencer coordinates items
        |
driver performs timed pin activity
        |
       DUT
        |
monitor publishes completed observations
        |-------------------|
        v                   v
predictor creates expected  coverage records occurrence
        |
        v
scoreboard compares expected with observed
```

This is the same reasoning used in FV-G1. UVM changes the standard containers
and connections, not the specification.

## 4. Lifecycle preview

UVM calls standardized phases. For now, recognize only the broad intent:

- **build:** create persistent structure and obtain configuration;
- **connect:** connect transaction paths between components;
- **run:** execute time-consuming stimulus, driving, monitoring, and checking.

Later modules teach exact phase rules. In the executable example, treat macros,
factory calls, and objections as annotated boilerplate—not material to memorize.

## 5. Mapping FV-G1

FV-G1's request struct resembles a future sequence item. Scenario tasks resemble
future sequences. The driver and monitor tasks already express the key UVM
driver and monitor ownership rules. The queue model and scoreboard already
express predictor and checking responsibilities.

The architectural lesson is therefore not “UVM makes verification correct.” It
is “UVM gives reusable standard form to verification boundaries that must
already be correct.”

## 6. Reading check

Before opening the worked example, predict why a monitor should not calculate
expected FIFO occupancy even though it can see DUT inputs and outputs.
