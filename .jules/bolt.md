## 2026-05-10 - Optimize Hash Functions to use pure ALU
**Learning:** Some hash functions like `hash12`, `hash13`, `hash14` have regressed or started using expensive trigonometric operations (`tan`, `atan`) which causes Special Function Unit (SFU) bottlenecks.
**Action:** When implementing or optimizing hash functions in GLSL shaders, prefer pure ALU-based operations (like Dave Hoskins' method) over trigonometric ones to reduce instruction cost and improve performance.
