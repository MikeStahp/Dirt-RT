## 2026-05-07 - Expensive Trig in GLSL Hash Functions
**Learning:** Using trigonometric functions (`tan`, `atan`, `cos`) inside tight GLSL loops like pseudo-random hash generation creates severe bottlenecks due to Special Function Unit (SFU) usage.
**Action:** Always prefer pure ALU-based hash generation methods (e.g., Dave Hoskins' `hash11`, `hash12`, etc., without trig). Avoid regressing into complex math when simple fract/dot/add instructions suffice.
