
## 2026-04-30 - GLSL Hash Function SFU Bottlenecks
**Learning:** The `hash12`, `hash13`, `hash14`, and generic `hash` functions were unnecessarily invoking expensive trigonometric operations (`tan`, `atan`, `cos`) which cause severe bottlenecks in the Special Function Units (SFU) of the GPU. Dave Hoskins' ALU-based methods are significantly faster and should be the standard.
**Action:** Always prefer pure ALU-based hash functions over trigonometric ones in GLSL shaders to reduce instruction cost and avoid SFU bottlenecks.
