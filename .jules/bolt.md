## 2026-06-28 - [Optimize GLSL math: pow() overhead]
**Learning:** In GLSL shaders, `pow(x, -2)` is extremely inefficient because it gets translated to expensive Special Function Unit (SFU) instructions: `exp2(-2 * log2(abs(x)))`. It should always be replaced by mathematically equivalent ALU operations.
**Action:** Replace `pow(abs(x), -2)` with `1.0 / (x * x)`. Since division by zero behaves the same (yielding infinity), no epsilon checks are needed. Any preceding `abs()` becomes mathematically redundant and can be safely removed.
