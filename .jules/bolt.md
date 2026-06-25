## 2026-06-25 - Expensive GLSL SFU Overhead in PBR Calculations
 **Learning:** Using `pow(abs(x), -2)` in GLSL triggers expensive Special Function Unit (SFU) evaluations (`exp2(-2 * log2(abs(x)))`). Mathematically, this is identical to `1.0 / (x * x)`, which relies purely on fast ALU operations, avoiding the SFU bottleneck and redundant `abs()` checks.
 **Action:** Always replace `pow(abs(x), -2)` with the reciprocal of the squared value (`1.0 / (x * x)`), caching any inner expressions (like dot products) in a local variable first to avoid redundant evaluations.
