## 2024-05-23 - Avoid Trigonometric Operations in GLSL Hashing
**Learning:** In GLSL shaders, ALU-based hash functions should be preferred over trigonometric ones (sin/cos/tan) to avoid GPU Special Function Unit (SFU) bottlenecks.
**Action:** Use purely ALU-based math (Dave Hoskins' method) for hash functions instead of trigonometric functions. Use `hash11(n)` instead of `fract(cos(n) * 41415.92653)` for simple hashing.
