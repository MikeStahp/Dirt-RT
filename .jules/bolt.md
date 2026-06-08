## 2026-06-08 - Expensive SFU operations in hash functions
**Learning:** In GLSL shaders, trigonometric operations like `tan` and `atan` inside hash functions cause significant overhead due to Special Function Unit (SFU) evaluations.
**Action:** Replace them with pure ALU operations (e.g., Dave Hoskins method) to avoid the bottleneck.
