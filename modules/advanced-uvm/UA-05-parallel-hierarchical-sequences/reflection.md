# UA-05 reflection

Answer concisely after the learner run and fault fixture.

1. Why does sequentially calling the two blocking `start()` methods prevent the
   rendezvous from proving concurrent child lifecycles?

- Sequentially calling the two start() methods prevent this process because the start() method is blocking, so it doesn't start the second one until the first one is done.

2. Why must concurrent traffic use two distinct sequence objects?

- We must use two distinct sequence objects because a single on gives conflicting ownership, especially around responses, and is not a good way to map two different traffics.

3. Why does this test check per-child completion instead of an exact global item
   order?

- The test checks per child completion because the exact global item order because the item order is not deterministic, the order is only gaurunteed within the scope of the child, and not globally.

4. Which command reproduces the sequential-child failure, and what report ID
   proves the concurrency invariant was violated?

- The .\tests\run-fixture.ps1 -Test ua05_sequential_child_test makes the failure, and UA05_CONCURRENCY id proves it was violated.
