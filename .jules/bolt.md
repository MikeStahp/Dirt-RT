## 2026-04-28 - Trigonometric Hash Functions Overhead
**Learning:** Trigonometric functions (sin, cos, tan, atan) in hash implementations cause severe performance bottlenecks due to high Special Function Unit (SFU) usage in shaders, particularly when used frequently like in FBM or noise functions.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' methods) over trigonometric ones to reduce instruction cost and improve rendering performance.
