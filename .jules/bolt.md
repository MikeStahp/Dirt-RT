## 2026-06-19 - GLSL pow() SFU Overhead
 **Learning:** Using `pow(abs(x), -2)` in GLSL incurs expensive Special Function Unit (SFU) overhead, and the `abs()` is mathematically redundant before squaring.
 **Action:** Always replace `pow(abs(x), -2)` with its mathematical equivalent `1.0 / (x * x)` to save ALU instructions, caching the inner expression in a local variable if necessary.
