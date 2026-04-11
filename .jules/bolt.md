## 2026-04-11 - [GLSL Hash Optimization]
**Learning:** In GLSL shaders, prefer pure ALU-based hash functions over those using expensive trigonometric operations (like `tan`, `atan`, `cos`) to prevent Special Function Unit (SFU) bottlenecks.
**Action:** Replace trig operations with ALU-based ones in hash functions like `hash12`, `hash13`, `hash14`, and `hash(float)`. Alias deprecated functions to optimized ones to prevent breaking dependencies.
