## 2026-05-23 - Avoid pow(abs(x), -2) in GLSL
**Learning:** In GLSL, evaluating `pow(x, -2)` utilizes expensive Special Function Units (SFUs) by computing `exp2(-2 * log2(abs(x)))`. Furthermore, taking the absolute value before squaring is mathematically redundant.
**Action:** Replace `pow(abs(x), -2)` with the mathematical equivalent `1.0 / (x * x)` to reduce SFU bottlenecks and ALU instruction count. Division by zero mathematically yields infinity in both cases, eliminating the need for epsilon mitigation.
