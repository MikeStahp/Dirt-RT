## 2026-05-20 - GLSL Reciprocal Square Optimization
**Learning:** In GLSL shaders, `pow(abs(x), -2)` involves redundant `abs()` checks and expensive Special Function Unit (SFU) evaluations (`exp2(-2 * log2(abs(x)))`). The division by zero case (`1.0 / 0.0`) is handled equivalently (yielding `inf`) in both methods, so it can be safely optimized to `1.0 / (x * x)`.
**Action:** When calculating reciprocals of squared values in GLSL shaders, replace `pow(abs(x), -2)` directly with `1.0 / (x * x)` to avoid SFU usage and unnecessary `abs()` evaluations.
