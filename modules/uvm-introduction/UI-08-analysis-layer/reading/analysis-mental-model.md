# Analysis layer mental model

## The observation boundary

A monitor's job is to observe an interface and reconstruct transactions. Once
it has an observation, it should publish that fact without knowing whether the
environment contains a scoreboard, coverage model, protocol logger, or all
three.

An `uvm_analysis_port #(T)` is the publisher endpoint. Calling `write(T)`
broadcasts to every endpoint connected to that port. Zero connections are
legal, so UVM cannot infer that a required checker was accidentally omitted;
the environment's self-checks must expose that fault.

## Two receiver shapes

`uvm_subscriber #(T)` already contains an `analysis_export` and requires its
derived class to implement `function void write(T item)`.

A custom component can instead own
`uvm_analysis_imp #(T, receiver_type)`. The implementation endpoint forwards
the incoming call to the owning component's `write(T)` function.

Both are terminal analysis receivers. They do not pull transactions and they
do not acknowledge completion.

## Lifecycle and direction

- Construct endpoints in constructors or build-time construction.
- Connect publisher port to receiver export/imp in `connect_phase`.
- Publish observations during runtime with `ap.write(item)`.
- Read data flow left-to-right: publisher to consumers.
- Read call implementation similarly: each connected receiver's `write()`
  executes during the publisher's call.

Because `write()` is a function, it consumes no simulation time. Keep lengthy
work elsewhere if a real environment needs it.

## Handle discipline

Every receiver sees the same object handle unless the publisher or receiver
explicitly clones. Read-only consumers can safely inspect it. A consumer that
mutates the item can make later consumers order-dependent, so this exercise
forbids mutation.
