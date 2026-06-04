
## 2026-06-04 - GLSL SFU Optimization: Reciprocal Squares
**Learning:** In GLSL, using `pow(x, -2)` or `pow(abs(x), -2)` triggers expensive Special Function Unit (SFU) evaluations like `exp2(-2 * log2(abs(x)))`. Replacing it with mathematical equivalents like `1.0 / (x * x)` saves instructions and avoids redundant `abs()` calls.
**Action:** Always replace `pow(abs(x), -2)` and `pow(x, -2)` with `1.0 / (x * x)`, and store inner functions (like dot products) in local variables to avoid redundant evaluation.
