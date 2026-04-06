## 2026-04-06 - Replacing Trig with ALU in GLSL Hashes
**Learning:** Found that `hash12`, `hash13`, `hash14` and `hash(float)` were using expensive trigonometric operations (tan/atan/cos). This causes heavy Special Function Unit (SFU) usage in shaders, slowing down execution, especially when these hashes are called in tight loops (like in noise functions).
**Action:** Use pure ALU Dave Hoskins hash algorithms and alias redundant ones instead.
