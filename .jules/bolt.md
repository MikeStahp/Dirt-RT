## 2026-07-05 - GLSL SFU Overhead Anti-Pattern
 **Learning:** This codebase's shaders sometimes use `pow(abs(x), -2)` for reciprocal squares. In GLSL, this evaluates to `exp2(-2 * log2(abs(x)))`, which triggers expensive Special Function Unit (SFU) instructions instead of pure ALU math.
 **Action:** Always replace `pow(x, -2)` with `1.0 / (x * x)` and extract the inner function evaluations into local variables to minimize redundant ALU instructions while completely avoiding SFU overhead.
