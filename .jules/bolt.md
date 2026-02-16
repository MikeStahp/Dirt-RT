## 2024-05-21 - Hash function bottleneck
**Learning:** The `hash(float)` function in `shaders/lib/common/hash.glsl` uses `cos` and is called heavily (40x per `fbm3D` call) in the ray tracing loop. This is a significant performance bottleneck as trig functions are expensive on GPUs compared to ALU operations.
**Action:** Replace `cos`-based hash with ALU-based hash (like Dave Hoskins' hash) for performance critical paths in shaders.
