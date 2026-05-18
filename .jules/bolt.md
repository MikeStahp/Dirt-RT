## 2026-05-18 - Avoiding SFU overhead with pow(x, -2)
**Learning:** In GLSL shaders, `pow(x, -2)` triggers expensive Special Function Unit (SFU) evaluations like `exp2(-2 * log2(abs(x)))`.
**Action:** Replace `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` to avoid SFU bottlenecks.
