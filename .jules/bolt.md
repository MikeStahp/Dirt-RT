## 2026-06-05 - SFU Overhead from pow(x, -2)
**Learning:** In GLSL, using `pow(abs(x), -2)` triggers expensive Special Function Unit (SFU) instructions (`exp2(-2 * log2(abs(x)))`). This is a common anti-pattern that slows down shader execution unnecessarily since it is mathematically equivalent to `1.0 / (x * x)`.
**Action:** Always replace `pow(x, -2)` with `1.0 / (x * x)` and remove any mathematically redundant `abs()` calls before squaring to save ALU instructions.
