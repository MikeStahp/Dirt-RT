## 2026-04-14 - Initializing Bolt Journal
**Learning:** Initializing journal for critical codebase-specific learnings.
**Action:** Always maintain this file as required by memory.
## 2026-04-14 - Optimization of GLSL Hash Functions
**Learning:** Found trigonometric operations (tan, atan, cos) in `hash12`, `hash13`, `hash14` and `hash(float)` inside `shaders/lib/common/hash.glsl`. These functions are frequently used in the noise and volumetric evaluation paths. SFU usage is a known bottleneck.
**Action:** Replace these expensive trig operations with ALU-based (Dave Hoskins method) equivalents as intended in the standard hash utility file. The generic `hash(float)` should alias `hash11(float)` to avoid trig entirely.
