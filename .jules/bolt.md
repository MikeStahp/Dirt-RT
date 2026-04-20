## 2026-04-20 - GLSL Hash Function SFU Bottlenecks
**Learning:** Using trigonometric functions like `tan()`, `atan()`, and `cos()` in GLSL hash functions creates a severe bottleneck on Special Function Units (SFUs), especially when called frequently like in noise functions.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' method using `fract` and `dot`) over trigonometric ones in GLSL shaders to reduce instruction cost and improve performance.
