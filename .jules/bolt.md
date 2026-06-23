## 2026-06-23 - Optimize pow() with reciprocal squares
 **Learning:** In GLSL shaders, replacing `pow(x, -2)` with `1.0 / (x * x)` avoids expensive Special Function Unit (SFU) overhead, omitting mathematically redundant `abs(x)` saves ALU instructions, and caching inner results like dot products prevents redundant evaluations.
 **Action:** When calculating the reciprocal of a squared value, omit `abs()`, explicitly use float literals (`1.0`), cache inner function results, and use pure ALU multiplication instead of `pow`.
