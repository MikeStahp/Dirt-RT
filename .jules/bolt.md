## 2026-06-09 - [GLSL SFU Overhead Optimization]
 **Learning:** Replacing `pow(x, -2)` with `1.0 / (x * x)` avoids expensive SFU overhead caused by `exp2(-2 * log2(abs(x)))` evaluations.
 **Action:** Always rewrite negative powers to their mathematically equivalent reciprocals of multiplications, avoiding `abs()` when the value is squared, and convert integer literals to floats.
