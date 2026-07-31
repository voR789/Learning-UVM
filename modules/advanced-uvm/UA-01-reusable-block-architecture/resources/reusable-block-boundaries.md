# Reusable block-level boundaries

## Observable problem

A testbench can work for one test and still be difficult to reuse. The usual
failure is misplaced ownership: a test drives pins directly, an environment
contains protocol timing, or a protocol agent contains a block-specific
scoreboard. Changing one policy then forces edits across unrelated classes.

## Compact mental model

Treat reuse as a dependency boundary:

```text
test
  selects scenario and configuration
        |
environment
  composes UVCs and block-level checking
        |
protocol UVC / agent
  owns protocol stimulus and observation
        |
interface
  owns the static signal boundary
```

A UVC is a reusable verification component for one interface or protocol. In
the block-level cases you have built, the agent is the core of that UVC.

## Ownership

| Decision or behavior | Natural owner | Reason |
| --- | --- | --- |
| Pin timing and request handshake | driver inside the UVC | Protocol-specific behavior travels with the protocol |
| Passive pin observation | monitor inside the UVC | Every reuse context needs the same transaction boundary |
| Active versus passive mode | configuration consumed by the UVC | Policy varies without duplicating implementation |
| DUT-specific prediction | block environment | It depends on block behavior, not merely the bus protocol |
| End-to-end comparison | block environment | It combines observations across block-level behavior |
| Scenario selection | test and sequences | Tests vary intent while reusing structure |
| Concrete HDL interface handle | top-level configuration boundary | Static HDL and dynamic UVM meet here |

## Configuration object

A configuration object groups policy that belongs together. It may carry
active/passive mode, virtual-interface handles, timing policy, feature enables,
or agent-specific knobs. The important rule is not “put everything in one
object.” It is:

> Put a decision in the lowest reusable configuration object that owns its
> meaning, and deliver it before the consuming component builds children that
> depend on it.

## Separate worked example

Imagine a serial-bus UVC reused twice around a bridge:

- the upstream instance is active and generates requests;
- the downstream instance is passive and observes traffic from an external
  controller;
- both use the same UVC class;
- each receives a different configuration object;
- the bridge environment owns the predictor that relates upstream requests to
  downstream observations.

Creating separate `active_bridge_env` and `passive_bridge_env` classes would
duplicate structure. Moving the bridge predictor into the serial agent would
make that agent block-specific and reduce protocol reuse.

## Failure mode

If a passive instance still constructs a driver, it can contend with the real
interface owner. If the monitor is removed, the environment loses observation.
If prediction moves into the driver, checking becomes dependent on stimulus
intent rather than independent observation.

## Prediction

If two block environments use the same protocol agent but require different
active/passive modes, which artifact should carry the difference while the
agent and environment classes remain unchanged?

## Local evidence

- `modules/uvm-introduction/UI-05-reusable-environment`
- `modules/uvm-basics/UB-04-build-connect-agent`
- `modules/uvm-basics/UB-G1-reusable-fifo-environment`
