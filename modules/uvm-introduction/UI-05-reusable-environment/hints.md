# UI-05 Progressive Hints

## Level 1: Diagnostic question

For each missing role, which component owns it, and is its existence
unconditional or controlled by `agent_active`?

## Level 2: Concept

The agent always observes and only drives when active. The environment owns
block-level reusable roles and passes structural policy downward before the
agent's build phase.

## Level 3: Location

Inspect only `ui05_agent::build_phase` and `ui05_env::build_phase`. Test
configuration and topology checks are complete.

## Level 4: Pseudocode

```text
agent build: create monitor; if active create driver
env build: create agent, predictor, scoreboard; set agent active from cfg
```

## Level 5: Minimal repair direction

Use factory creation with the exact required instance names and `this` parent.
Assign `agent.is_active` after agent creation and before returning from env build.

## Level 6: Reference direction

Create `monitor` unconditionally, `driver` under `if (is_active)`, then create
`agent`, `predictor`, and `scoreboard` in the environment and copy
`cfg.agent_active` to `agent.is_active`.
