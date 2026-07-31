# UA-02 reflection

Answer concisely after both learner tests pass.

1. Why does direct construction with `new()` prevent a factory override from
   taking effect?

- Direct construction with `new()` prevents factory overrides because the normal method on instantiation bypasses the entire factory system. The factory system is what allows for overrides, because it takes in override calls, and changes it's instantiation procedure.

2. What changes under a type override compared with an instance override?

- Instance overrides only change the instantiation of one specific component instance path, compared to type overrides, which change the instantiation of an entire component.

3. Why are the left and right operands configuration data rather than separate
   derived component types?

- The operands are configuration data because each policy instance can use different values without needing a different implementation. Derived policy classes are for changing behavior, while configuration tunes that behavior per instance.

4. Why must the override be installed before the environment creates its
   policy components?

- The override must be installed before because the factory cannot go back in retrospect and change instances that have already been constructed.

5. Which command and seed reproduce the wrong-instance-path failure?

- The command:.\tests\run-fixture.ps1 -Test ua02_wrong_path_test
