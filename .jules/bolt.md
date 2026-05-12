
## 2026-05-12 - Replace pow(x, -2) with 1.0 / (x * x)
**Learning:** In GLSL shaders, evaluating `pow(x, -2)` utilizes the Special Function Unit (SFU) because it is typically expanded to `exp2(-2 * log2(abs(x)))`. This introduces unnecessary computational overhead.
**Action:** Replace `pow(x, -2)` with the mathematical equivalent `1.0 / (x * x)` to avoid SFU operations and improve performance.
