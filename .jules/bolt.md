## 2026-05-22 - Avoid pow(x, -2) in GLSL
**Learning:** In GLSL, `pow(x, -2)` evaluates to `exp2(-2 * log2(abs(x)))`, which invokes expensive Special Function Unit (SFU) instructions.
**Action:** Replace `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)`, which is a cheaper ALU instruction and inherently resolves negative base values gracefully.
