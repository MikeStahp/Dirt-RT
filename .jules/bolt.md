## 2026-06-16 - GLSL SFU Overhead from pow()
 **Learning:** Using `pow(x, -2)` inside GLSL shaders causes significant Special Function Unit (SFU) overhead because it compiles down to `exp2(-2.0 * log2(abs(x)))`.
 **Action:** Always replace `pow(x, -2)` with its mathematical ALU equivalent `1.0 / (x * x)` and remove redundant `abs()` calls to avoid SFU evaluations.
