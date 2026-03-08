

## 2024-11-20 - [ALU over Trig for GLSL Hashes]
**Learning:** Found that `hash12`, `hash13`, `hash14` and `hash()` in `shaders/lib/common/hash.glsl` were using expensive trigonometric operations (`tan`, `atan`, `cos`) which creates Special Function Unit (SFU) bottlenecks. 3D value noise uses `hash()` heavily.
**Action:** Avoid trigonometric operations in noise / random number generation. Prefer standard ALU-based hashes like Dave Hoskins' implementation (already present in other hash variants in the same file).
