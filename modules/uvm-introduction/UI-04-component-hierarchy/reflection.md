# UI-04 Reflection

Answer after the hierarchy lab passes.

1. How does `run_test()` know which registered test class to construct in this
   runner?
- `run_test()` knows which test class to construct and run thanks to a command arguement specifying which.
2. Why are `container` and `leaf` created during `build_phase` rather than
   `run_phase`?
- Container and leaf are constructed during build phase because the build phase is when we create all of the components. Making them in the run phase would cause issues if it ran before a component was built. The later phases, such as connect phase and run phase rely on the fact that the build phase has already built permanent components.
3. In `type_id::create("leaf", this)`, what determines the class type, handle,
   short instance name, parent, and resulting full path?
- The class type is determined by the class type specifier in <class_type>::type_id... the handle is determined by the left handle of the line, as  the create() function makes the instance, which is assigned to the left hand side. The short instance name is defined by the first arguement of create(), the parent is determined by the second arguement, and the full path is determined by both as it will be `<this.name>.leaf`.
1. What path did the wrong-parent fixture produce, and why did topology expose
   the ownership error?
- It produced uvm_test_top.leaf, and the topology exposed that we were missing the "container" layer of ownership.
1. What do run-phase objections guarantee, and what do they not guarantee?
- Run-phase objections guaruntee that a phase will not end whilst an objection is raised, it does not guaruntee that the work done by the phase is done or correct.