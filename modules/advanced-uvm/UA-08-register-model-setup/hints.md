# UA-08 hints

Reveal one level at a time.

## Level 1: diagnostic question

Which objects belong to the operation path, and which object belongs to the
observation path that updates the mirror?

## Level 2: concept

The map and adapter serve both paths: the map defines addresses, while the
adapter translates generic register operations and completed bus items.

## Level 3: location

Inspect `ua08_reg_block::build()` for model topology and
`ua08_env::connect_phase()` for frontdoor and predictor integration.

## Level 4: pseudocode

Build one register under one little-endian byte-addressed map, then give the map
a sequencer/adapter and give the predictor that same map/adapter plus completed
bus observations.

## Level 5: minimal repair direction

Keep construction in the block and connectivity in the environment. Disable
auto-predict before relying on observed bus traffic for mirror updates.

## Level 6: reference solution

Request the reference implementation explicitly only after showing the current
failure and explaining which path is incomplete.
