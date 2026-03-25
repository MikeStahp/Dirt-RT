## 2024-05-24 - [ALU Hash Optimization]
**Learning:** In GLSL shaders, trigonometric functions (`tan`, `atan`, `cos`, `sin`) use Special Function Units (SFUs), which are heavily bottlenecked in core loop functions. Dave Hoskins' hash methods should be strictly ALU-based to prevent SFU bottlenecks.
**Action:** When inspecting hash functions, ensure they do not regress to using expensive trigonometric operations. Replace them with pure ALU-based operations (fract, dot, +, *) for a measurable performance increase, especially in heavily sampled functions like `noised`.
