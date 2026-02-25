## 2024-05-23 - Trig-based Hash Function Bottleneck
**Learning:** The codebase used a trigonometric hash function (`fract(cos(n)*C)`) in `shaders/lib/common/hash.glsl`, which was heavily used by `noised` and `fbm3D` (40+ calls per ray in some cases). This is a performance anti-pattern in GLSL as `cos` uses SFUs and has high latency.
**Action:** Replace `cos`-based hashes with ALU-based hashes (like Dave Hoskins' `hash11`) whenever found in shader code to improve instruction throughput.
