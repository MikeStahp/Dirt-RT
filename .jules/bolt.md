## 2026-04-24 - GLSL Hash Function SFU Bottlenecks
**Learning:** Trigonometric functions (`tan`, `atan`, `cos`) used in procedural hash functions severely bottleneck performance on Special Function Units (SFUs) in the GPU, especially when called inside multi-octave noise functions (e.g., `fbm3D`, `noised`).
**Action:** Always prefer pure ALU-based hash implementations (like Dave Hoskins' method) over legacy trigonometric hashes in performance-critical shader paths.
