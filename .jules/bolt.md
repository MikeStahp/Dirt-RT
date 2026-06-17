## 2026-06-17 - GLSL Reciprocal Square Optimization
 **Learning:** In GLSL shaders, `pow(abs(x), -2)` is evaluated using computationally expensive `exp2` and `log2` Special Function Unit (SFU) instructions. Furthermore, applying `abs()` before squaring is mathematically redundant.
 **Action:** Replace `pow(abs(x), -2)` with the mathematically equivalent `1.0 / (x * x)` to avoid SFU overhead. Additionally, store inner expressions in local variables if they are reused, to prevent redundant evaluations.
