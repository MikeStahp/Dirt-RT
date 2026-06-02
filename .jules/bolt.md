## 2026-06-02 - [GLSL SFU Overhead Pattern]
**Learning:** The codebase has a pattern of using `pow(x, -2)` for squaring reciprocals. This triggers expensive Special Function Unit (SFU) evaluations `exp2(-2 * log2(abs(x)))` in GLSL which slows down shader execution. Furthermore, preceding it with `abs(x)` is mathematically redundant.
**Action:** Always replace `pow(abs(x), -2)` and `pow(x, -2)` with `1.0 / (x * x)` to bypass the SFU overhead and eliminate redundant ALU instructions while maintaining exact mathematical parity (including division by zero edge cases).
