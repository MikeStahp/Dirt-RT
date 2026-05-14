
## 2026-05-14 - GLSL SFU Overhead with Pow
**Learning:** In GLSL, using pow(x, -2) for inverse square calculations triggers expensive Special Function Unit (SFU) instructions (exp2 and log2) that bottleneck per-fragment execution.
**Action:** Always replace pow(x, -2) with its mathematical equivalent 1.0 / (x * x) to leverage standard fast ALU multiplications.
