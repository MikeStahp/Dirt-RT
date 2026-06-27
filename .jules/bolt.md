## 2026-06-27 - [GLSL SFU Overhead Optimization]
 **Learning:** In GLSL shaders, replacing pow(abs(x), -2) with its mathematical equivalent 1.0 / (x * x) avoids expensive Special Function Unit (SFU) overhead caused by exp2(-2 * log2(abs(x))) evaluations. Storing inner operations like dot products in local variables prevents redundant recalculations when squaring.
 **Action:** Always replace pow(x, -2) with reciprocal squares and cache intermediate values in GLSL to reduce ALU and SFU instructions.
