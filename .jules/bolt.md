## 2026-05-29 - GLSL pow() function overhead
**Learning:** In GLSL, replacing `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` avoids expensive Special Function Unit (SFU) overhead caused by `exp2(-2 * log2(abs(x)))` evaluations. Additionally, `abs(x)` is mathematically redundant before squaring.
**Action:** Always replace `pow(x, -2)` with `1.0 / (x * x)` in GLSL code to optimize ALU operations.
