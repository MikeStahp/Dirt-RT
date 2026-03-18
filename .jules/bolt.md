
## 2024-05-24 - Prefer ALU-based hash functions over trigonometric ones
**Learning:** Using trigonometric functions (tan, atan, cos) in hash functions creates significant Special Function Unit (SFU) bottlenecks in this GLSL codebase.
**Action:** Always prefer pure ALU-based hash functions (e.g., hash11, Dave Hoskins' method) over trigonometric ones in GLSL to reduce instruction cost and avoid SFU bottlenecks.
