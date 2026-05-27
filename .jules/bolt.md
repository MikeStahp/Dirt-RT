## 2026-05-27 - [GLSL SFU Overhead with pow()]
**Learning:** Using `pow(x, -2)` in GLSL triggers expensive Special Function Unit (SFU) evaluations (like `exp2` and `log2`), adding unnecessary overhead when it can be mathematically simplified. Additionally, `abs(x)` before squaring is mathematically redundant.
**Action:** Replace `pow(abs(x), -2)` with the more efficient ALU instruction `1.0 / (x * x)` to avoid SFU overhead. Division by zero edge cases are mathematically identical (yielding `inf`), so no epsilon mitigation is needed.
