## 2026-06-12 - GLSL Reciprocal Square Optimization
**Learning:** In GLSL shaders, operations like `pow(x, -2)` cause significant overhead due to evaluations like `exp2(-2 * log2(abs(x)))` in the Special Function Unit (SFU). Replacing them with the mathematically equivalent `1.0 / (x * x)` avoids this overhead and saves ALU instructions.
**Action:** Always replace `pow(x, -2)` with `1.0 / (x * x)` in GLSL to optimize code, ensuring the inner calculation is stored in a local variable if it's complex to avoid redundant evaluations.
