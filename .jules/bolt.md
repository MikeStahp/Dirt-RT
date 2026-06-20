## 2026-06-20 - GLSL SFU Overhead from pow()
**Learning:** In GLSL shaders, replacing `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` avoids expensive Special Function Unit (SFU) overhead caused by `exp2(-2 * log2(abs(x)))` evaluations. Any preceding `abs(x)` is mathematically redundant. Division by zero edge cases are mathematically identical (both yield `inf`), making it safe without an epsilon.
**Action:** Always replace `pow(x, -2)` with the reciprocal of the square, and store the inner function (like a dot product) in a local variable first to avoid redundant evaluations.
