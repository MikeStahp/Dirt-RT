## 2026-05-28 - GLSL Math Optimization: pow(x, -2) vs Reciprocals
**Learning:** Found a performance anti-pattern in GLSL where `pow(abs(x), -2)` is used for inverse squared values. This is computationally expensive as `pow()` uses Special Function Units (SFU). Additionally, the `abs()` before squaring is mathematically redundant.
**Action:** Replace `pow(abs(x), -2)` with `1.0 / (x * x)` to leverage faster ALU instructions and avoid SFU overhead.
