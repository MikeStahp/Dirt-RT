## 2024-05-24 - [Avoid Trigonometric Operations in Hash Functions]
**Learning:** Using trigonometric functions like `cos`, `tan`, and `atan` in GLSL hash functions causes massive Special Function Unit (SFU) bottlenecks, particularly because these hashes are called many times per invocation by functions like `noised` and `fbm3D`.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' method or simpler `fract`/`dot` compositions) over trigonometric-based ones in shader code.
