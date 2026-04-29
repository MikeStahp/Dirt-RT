## 2026-04-29 - Avoiding SFU Bottlenecks in GLSL Hash Functions
**Learning:** Using trigonometric operations (`tan`, `atan`, `cos`) in heavily used GLSL hash functions (e.g. `hash12`, `hash13`, `hash14`, `hash(float)`) causes significant Special Function Unit (SFU) bottlenecks, reducing shader performance.
**Action:** Always prefer pure ALU-based operations (like the Dave Hoskins method) for hash functions to minimize SFU instruction overhead and improve overall performance in the codebase.
