# UI-10 reflection

Answer in your own words after the executable test passes.

1. Why is the coverage subscriber's `write()` the authoritative sampling
   boundary in this exercise?
- The coverage subscriber's `write()` implementation acted as the authoritative sampling boundary because it allowed a level of abstraction between the monitor and the covergroups, allowing us to change our coverage without having to mess with the monitor. Each call represents one sampled transaction.
2. How can both coverpoints reach 100% while their cross remains incomplete?
- The coverpoints can reach 100% while their cross is not 100% by not occuring at the same time. For example, each operation can be reached, but if each operation is not reached with zero and without, the cross will not be fully covered.
3. What do `published=8` and `samples=8` prove, and what do they not prove?
- The matching published count and sample count prove that the subscriber successfully sampled an equal of the monitor's observations that were published. This not not prove that the implementation after that, or the coverage itself is correct, or that the transactions themselves are equal.
4. Why does 100% functional coverage not prove the observed results were
   correct?
- It does not prove the observed results are correct because that responsibility comes to the scoreboard, the coverage only indicates that transaction scenarios or combinations occur.
5. What new coverage consumer or bin could be added without changing the
   publisher?
- Any new consumer or bin that does not involve new signals can be added without changing the publisher because our use of the analysis layer abstracts our implementation from our publishing.
