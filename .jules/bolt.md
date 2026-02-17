## 2024-05-22 - Replacing Trigonometric Hash
**Learning:** Trigonometric functions like `cos` in hash functions are significantly more expensive than ALU-based operations (fract, dot) and can be a bottleneck in noise generation.
**Action:** Prefer ALU-based hash functions (like Dave Hoskins' "Hash without Sine") for procedural generation and noise in shaders.
