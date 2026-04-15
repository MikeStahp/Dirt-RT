## 2026-04-15 - GLSL Hash Function Performance Optimization
**Learning:** In GLSL shaders, using trigonometric functions (`tan`, `atan`, `cos`) for hashing calculations creates a massive performance bottleneck because they execute on the limited Special Function Units (SFUs), heavily impacting parallel compute capabilities.
**Action:** Always prefer ALU-based hash functions (like Dave Hoskins' method) over ones involving trig operations, ensuring calculations stay on the standard ALUs to maximize performance throughput.
