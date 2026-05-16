## 2026-05-16 - GLSL Math Optimization: SFU Overhead from pow()
**Learning:** In GLSL shaders, using `pow(x, -2)` incurs expensive Special Function Unit (SFU) overhead because it is typically evaluated as `exp2(-2.0 * log2(abs(x)))` at runtime. This causes unnecessary pipeline stalls.
**Action:** Replace `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` to bypass the SFU and use much faster standard ALU operations (multiplication and division).
