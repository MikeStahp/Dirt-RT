## 2026-04-27 - [Replace Trig in GLSL Hash]
**Learning:** Using trigonometric functions (like `cos()`) in GLSL hash functions that are called frequently (like inside noise functions) causes severe Special Function Unit (SFU) bottlenecks.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' `hash11`) over trig-based ones, especially when they are aliased or wrapped by widely used utility functions like `noised`.
