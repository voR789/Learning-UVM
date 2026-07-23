# UI-01 Reflection

Answer after the architecture map passes semantic review.

1. What problem does UVM solve that FV-G1 had to solve with custom tasks, mailboxes, events, and orchestration?
- UVM standardizes verification by providing a abstraction layer for common components, such that pieces can easily be reused and swapped in and out. It also provides a clear hierarchy that helps prevent issues.
2. Why is a sequence item an object rather than a persistent component?
- The sequence item is an object because it serves only as a *temporary* instruction for the DUT, and is dynamically created and destroyed.
3. Which FV-G1 ownership boundary would be most dangerous to lose during a UVM rewrite, and what failure could result?
- The most dangerous ownership boudndary to lose during a UVM rewrite would probably be the predictor boundary, as it's the main player that validates our DUT (by generating the "answer key"). By failig the predictor boundary, we could get no explicit errors, but hidden logical errors as the expected results become invalid.
4. What verification knowledge must still come from the DUT specification even after adopting UVM?
- The predictor must still use the DUT specification in order to implement an indpendent model, even after using UVM. The sequences are still based on the requirements of the hardware speec, the coverage goals aim to cover the goals of the hardware spec.
5. Which part of the executable hierarchy example remains unclear and should be taught before you implement it?
- Honestly, the class creation and inheritance syntax is familiar, but unclear still to me. I want to understand the explicit rules and how everything goes.
