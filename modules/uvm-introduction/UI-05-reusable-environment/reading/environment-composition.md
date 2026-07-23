# Environment composition: group by reuse boundary

## Agent

An agent groups roles tied to one protocol interface. In active mode it can
stimulate and observe; in passive mode it only observes.

```text
active agent  = driver + monitor   (sequencer arrives in UI-07)
passive agent = monitor
```

A passive agent must not drive because it may be attached to an interface
owned by another verification component or real system master.

## Environment

An environment contains reusable verification structure for the DUT or block:

```text
environment
├── one or more agents
├── predictor/reference model
├── scoreboard
└── later: coverage and transaction connections
```

Protocol pin ownership belongs inside the agent. Cross-component checking and
block-level prediction belong at environment scope.

## Test

The test chooses policy: configuration and scenario intent. It should not
reimplement the environment merely to choose active versus passive behavior.

## Configuration object

A configuration object groups decisions instead of scattering independent
flags. In this module the test creates `ui05_env_config`, selects `agent_active`,
then gives the handle to the environment before the environment builds.

Top-down build ordering makes this possible:

```text
test.build: create cfg, create env, assign env.cfg
    ↓
env.build: create agent, copy cfg choice into agent
    ↓
agent.build: always create monitor; conditionally create driver
```

This is direct handle propagation for clarity. A later module introduces
`uvm_config_db` for hierarchy-scoped delivery.

## Invariant

Configuration changes policy, not ownership:

- The agent still owns its driver and monitor.
- The environment still owns its agent, predictor, and scoreboard.
- The test selects active/passive behavior without constructing those internal
  children itself.

## Reading check

If the test directly creates the agent's driver, which reuse boundary has been
broken and why?
