
## 2026-05-26 - [GLSL SFU Overhead from pow(x, -2)]
**Learning:** In GLSL, using `pow(x, -2)` evaluates to `exp2(-2 * log2(abs(x)))`, which causes expensive Special Function Unit (SFU) overhead.
**Action:** Always replace `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)`. A preceding `abs(x)` is also mathematically redundant in this case and should be omitted to save ALU instructions.
