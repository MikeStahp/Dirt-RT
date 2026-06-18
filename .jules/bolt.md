## 2026-06-18 - GLSL Reciprocal Square Optimization
 **Learning:** In GLSL, replacing `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` avoids expensive Special Function Unit (SFU) overhead caused by `exp2(-2 * log2(abs(x)))` evaluations. Furthermore, any preceding `abs(x)` operation is mathematically redundant before squaring and should be omitted to save ALU instructions.
 **Action:** Always look for `pow(x, -2)` or `pow(abs(x), -2)` patterns in shaders and replace them with reciprocal squares, storing the inner calculation in a local variable to avoid redundant evaluations.
