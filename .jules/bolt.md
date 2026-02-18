## 2024-10-24 - Trigonometric Hash Functions in GLSL
**Learning:** Found heavily used hash functions (hash12, hash13, hash14) implementing bizarre trigonometric patterns (tan(dot(...) * atan(...))). These are extremely slow compared to standard ALU hashes and likely copy-paste errors or misguided "quality" improvements.
**Action:** Always inspect hash implementations in GLSL shaders. Replace trigonometric hashes with standard Dave Hoskins "Hash without Sine" variants for immediate performance wins on critical paths like noise generation.
