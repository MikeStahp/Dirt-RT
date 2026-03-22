
## 2024-05-14 - Replace trigonometric operations with ALU hashes
**Learning:** In GLSL shaders, especially for Vulkanite path tracing, expensive trigonometric operations like `tan`, `atan`, and `cos` in frequently invoked functions such as noise and hash functions create massive Special Function Unit (SFU) bottlenecks.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' method without trig functions) to improve performance by reducing SFU pressure, as seen in the `hash` family of functions.
