## 2026-04-09 - [Trigonometric Bottlenecks in GLSL Hashes]
**Learning:** [Trigonometric functions like `tan`, `atan`, and `cos` in foundational utility functions like `hash(float)` can cause severe Performance bottlenecks in GLSL shaders due to high Special Function Unit (SFU) usage, especially when called repeatedly in loops or layered noise functions.]
**Action:** [Use pure ALU-based hash methods (like Dave Hoskins' hash implementations) for pseudo-random number generation in GLSL to minimize instruction cost and avoid overloading SFUs.]
