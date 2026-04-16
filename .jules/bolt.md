
## 2026-04-16 - GLSL Hash Function Optimization
**Learning:** Using trigonometric functions (`tan`, `atan`, `cos`) in GLSL hash functions creates severe Special Function Unit (SFU) bottlenecks. Pure ALU-based methods (like Dave Hoskins' hash) provide significantly better performance, especially when called frequently in noise generation (e.g., `noised` calling `hash(float)` eight times).
**Action:** Prefer ALU-based operations over trigonometric ones for hash/noise generation in shaders. Ensure wrapper functions like `hash(float)` delegate to efficient ALU implementations (e.g., `hash11(n)`) rather than falling back to slower trigonometric methods.
