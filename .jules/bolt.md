## 2026-05-31 - [Hash Functions Optimization]
**Learning:** In GLSL, trigonometric operations like `tan` and `atan` inside hash functions (e.g. `hash12`, `hash13`, `hash14`) cause significant overhead due to Special Function Unit (SFU) evaluations. Replacing these with pure ALU operations, like Dave Hoskins' method, improves performance.
**Action:** Replaced expensive `tan` and `atan` with pure ALU operations in `hash12`, `hash13`, `hash14`. Also optimized the `hash(float)` function which incorrectly used `cos` and made it an alias to `hash11`.
