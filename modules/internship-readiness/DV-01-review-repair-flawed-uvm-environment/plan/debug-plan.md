# Debug plan — learner owned

## Pre-edit prediction

- The FIFO consumer will read the field at the time it recieves the handle, and since the publisher sends a alias, not a copy, it will cause issues.

<!-- Where do you predict the first bad evidence will appear, and why? -->

## One-sentence root-cause hypothesis

- The monitor is not properly sending the handle in a way that protects the transaction object.

<!-- Write this after the first run and before editing code. -->

## Smallest proposed repair

- Change the monitor sending semantics.

<!-- Name the violated contract and the boundary you will change. -->
