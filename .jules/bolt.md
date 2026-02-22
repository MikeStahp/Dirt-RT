## 2024-05-23 - GLSL Hash Performance
**Learning:** Trigonometric functions (sin/cos) in GLSL hash functions are significantly slower than ALU-based alternatives (fract/mul/add) because they run on Special Function Units (SFUs). In heavy consumers like noise generation (e.g., `noised` calling hash 8 times), this becomes a bottleneck.
**Action:** Always prefer ALU-based hash functions (like Dave Hoskins' hashes) over trigonometric ones in shader code, especially for noise generation.
