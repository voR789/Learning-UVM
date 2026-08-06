# Honest coverage closure

## Observable problem

A report contains uncovered bins. One may represent missing stimulus; another may represent behavior prohibited by the specification. Treating both the same either wastes effort or hides risk.

## Mental model

For each hole, choose one disposition:

- **Reachable and required:** add focused stimulus and observe the bin.
- **Unreachable by specification:** retain evidence linking the exclusion to a requirement.
- **Unknown:** run a discriminating experiment or clarify the specification.

Governing invariant: **a reachable requirement may be closed only by an authoritative observation; an exclusion is valid only when the specification makes the behavior impossible or out of scope.**

## Separate example

A four-channel block exposes only channels 0–2. An uncovered channel-2 write needs targeted stimulus. Channel 3 is unreachable by interface contract and may be excluded with that citation. Relabeling the channel-2 bin as ignored would increase the percentage without improving verification.

## Prediction

What would a passing coverage percentage fail to prove if the stimulus code directly edited the coverage model's internal flags?
