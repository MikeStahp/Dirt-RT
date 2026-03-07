## 2024-05-24 - Trigonometric Function Bottlenecks in GLSL Hashing
**Learning:** Using trigonometric functions like `cos()`, `sin()`, or `tan()` in GLSL hash functions (e.g., `hash(float n)`) causes significant Special Function Unit (SFU) bottlenecks, especially when these functions are called repeatedly in nested loops by noise functions like `noised()` or `fbm3D()`.
**Action:** Always prefer ALU-based hash functions (like Dave Hoskins' methods, e.g., `hash11(n)`) over trig-based ones in shader code to improve instruction throughput and reduce SFU usage.
