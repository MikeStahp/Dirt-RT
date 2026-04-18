## 2026-04-18 - GLSL Hash Function Optimization
**Learning:** Using trigonometric functions (`tan`, `atan`, `cos`) in GLSL hash functions causes significant Special Function Unit (SFU) bottlenecks. Pure ALU-based methods (like Dave Hoskins' method) are much more performant.
**Action:** Ensure all hash implementations (`hash12`, `hash13`, `hash14`, `hash`) use strictly pure ALU-based operations. Alias redundant hash functions to prevent code duplication while avoiding compilation errors in downstream dependencies.
