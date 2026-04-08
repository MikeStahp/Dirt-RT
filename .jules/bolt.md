## 2026-04-08 - Avoid Trigonometric Functions in Hash Algorithms
**Learning:** In GLSL, trigonometric functions like `tan` and `atan` are heavily bottlenecked by Special Function Units (SFUs), making them a poor choice for high-frequency operations like pseudo-random number generation (PRNG).
**Action:** Ensure hash functions in the standard library (e.g., `hash12`, `hash13`, `hash14`, and the default `hash` wrapper) use pure ALU operations (Dave Hoskins' method) to maximize performance, especially since they are invoked frequently in critical paths like noise generation.
