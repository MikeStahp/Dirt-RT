## 2024-05-24 - Pure ALU Hash Functions
**Learning:** In GLSL shaders, especially in critical paths like path tracing and noise generation (`fbm3D`, `noised`), using trigonometric operations (`tan`, `atan`, `cos`) in hash functions (`hash12`, `hash13`, `hash14`, `hash(float)`) causes severe performance bottlenecks due to high Special Function Unit (SFU) utilization.
**Action:** Always use Dave Hoskins' pure ALU-based hash methods (e.g., fractional dot products) instead of trig-based methods to improve performance by reducing instruction cost and SFU overhead.
