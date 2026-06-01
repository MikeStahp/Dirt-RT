## 2024-06-01 - GLSL pow() SFU Overhead

**Learning:** Replacing pow(abs(x), -2) with 1.0 / (x * x) removes mathematically redundant abs() calls and avoids expensive Special Function Unit (SFU) overhead from log2/exp2.

**Action:** Always replace pow(x, -2) with explicit division and multiplication in GLSL shaders.