## 2026-06-03 - GLSL SFU Overhead Avoidance
**Learning:** In GLSL, using `pow(abs(x), -2)` invokes expensive Special Function Unit (SFU) evaluations (`exp2` and `log2`). Additionally, `abs(x)` before squaring is mathematically redundant.
**Action:** Always replace `pow(x, -2)` or `pow(abs(x), -2)` with the explicit reciprocal of a squared value `1.0 / (x * x)` and ensure literals are floats to maintain type safety.
