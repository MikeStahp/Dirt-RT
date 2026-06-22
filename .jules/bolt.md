## 2026-06-22 - GLSL SFU Overhead
**Learning:** In GLSL shaders, `pow(x, -2)` causes expensive Special Function Unit (SFU) overhead because it expands to `exp2(-2 * log2(abs(x)))`. Also, `abs(x)` is mathematically redundant before squaring.
**Action:** Replace `pow(abs(x), -2)` with `1.0 / (x * x)` to use pure ALU instructions and avoid SFU overhead. Store `x` in a local variable to prevent redundant evaluation.
