## 2026-07-04 - GLSL `pow()` SFU Bottleneck
 **Learning:** Found instances where `pow(abs(x), -2)` was used in shader code. In GLSL, this evaluates to `exp2(-2 * log2(abs(x)))`, which incurs expensive Special Function Unit (SFU) overhead compared to mathematical equivalents like `1.0 / (x * x)`.
 **Action:** Always refactor `pow(x, -2)` to `1.0 / (x * x)` in GLSL shaders, extracting inner expressions into local variables to avoid redundant evaluations, and omit unnecessary `abs()` calls.
