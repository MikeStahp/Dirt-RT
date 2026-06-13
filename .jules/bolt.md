## 2026-06-13 - [GLSL SFU Overhead with pow]
 **Learning:** In GLSL shaders, calculating `pow(abs(x), -2)` involves expensive Special Function Unit (SFU) evaluations like `exp2(-2 * log2(abs(x)))`. Replacing it with mathematical equivalents like `1.0 / (x * x)` avoids this overhead. Additionally, `abs(x)` is redundant before squaring.
 **Action:** Always replace `pow(abs(x), -2)` with `1.0 / (x * x)` in shaders to improve ALU efficiency and avoid SFU bottlenecks.
