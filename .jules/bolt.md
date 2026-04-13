## 2026-04-13 - Remove trigonometric bottlenecks in hash functions
**Learning:** In GLSL shaders, using trigonometric operations like `tan`, `atan`, and `cos` in core hash functions creates significant bottlenecks because they rely on the Special Function Unit (SFU) rather than standard ALUs. This severely limits performance since hash functions are called extensively in rendering tasks like noise generation.
**Action:** Always prefer ALU-based hash functions over trigonometric ones to reduce instruction cost and prevent SFU saturation.
