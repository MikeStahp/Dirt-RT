## 2024-05-22 - Optimize Hash Functions
**Learning:** In GLSL shaders, using trigonometric functions (`tan`, `atan`, `cos`) in heavily called procedural generation functions like `hash(float n)`, `hash12`, `hash13`, `hash14` triggers significant SFU (Special Function Unit) bottlenecks. Pure ALU operations like Dave Hoskins' methods are vastly superior for these paths.
**Action:** When working on shader math, ALWAYS prefer Dave Hoskins' ALU methods for hash functions over trigonometric approximations. Verify any `hash()` style utility functions map to their ALU counterparts.
