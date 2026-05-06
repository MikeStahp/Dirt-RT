## 2026-05-06 - GLSL Hash Function Bottlenecks

**Learning:** Trigonometric functions like `tan` and `atan` used inside hash functions (e.g., `hash12`, `hash13`, `hash14`) introduce significant Special Function Unit (SFU) bottlenecks on the GPU. The codebase relies heavily on pure ALU-based hash functions (Dave Hoskins' method) to maximize performance.

**Action:** Always verify that hash functions strictly use pure ALU-based operations. Ensure aliases like `fasthash13` point to the optimized `hash13` implementation, and `hash(float)` points to `hash11` to maintain backward compatibility without regressing to expensive trigonometric operations like `cos`.
