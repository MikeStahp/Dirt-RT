## 2026-07-07 - [GLSL SFU Overhead]
 **Learning:** Using `pow(x, -2)` triggers expensive Special Function Unit (SFU) evaluations via `exp2(-2 * log2(abs(x)))` in GLSL.
 **Action:** Replace `pow(x, -2)` with `1.0 / (x * x)` and extract the inner expression into a local variable to avoid redundant computation, omitting redundant `abs()` calls.
