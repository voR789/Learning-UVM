# UI-02 Reflection

Answer after the policy lab passes.

1. What is inherited from `check_policy`, and what behavior is overridden?
-  The two functions `accept()` and `policy_name` are inherited from the original check policy class, and both of their behaviors are overwritten.
2. Why can the caller use a `check_policy` handle for both derived objects?
- Because the dervied objects are both child classes of `check_policy`, the caller can use a generic handle for each. Since the child classes inherit the parent classes' functions, there is no danger of undefined calls.
3. What incorrect result occurs for the near-match case if the base `accept`
   method is not virtual, and why?
- Without virtual, the near-match case resolves as failed (0), because the lack of the `virtual` keyword makes it so the parent classes' function cannot be overwritten.
4. How does this design let a verification test change comparison policy
   without rewriting the caller?
- We can make the class a child class of the caller handle, and make the functions virtual such that we can write a special case for the comparison policy, and yet use the same handle. We only then need to change the handle assignment.
5. Which part of inheritance, handles, or virtual dispatch remains unclear?
- None, I'm ready to move to the next step, but still in the space of UVM syntax.
