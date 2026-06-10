## 2026-06-10 - GLSL SFU Overhead from pow(x, -2)
 **Learning:** In GLSL, `pow(abs(x), -2)` causes expensive Special Function Unit (SFU) overhead because it evaluates as `exp2(-2.0 * log2(abs(x)))`. The `abs()` is also mathematically redundant before squaring.
 **Action:** Always replace `pow(abs(x), -2)` with `1.0 / (x * x)` and cache the inner function (e.g., dot products) to save ALU instructions. Division by zero yields `inf` in both cases, making it safe without epsilon mitigation.
