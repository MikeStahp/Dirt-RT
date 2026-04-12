## 2026-04-12 - GLSL Hash Function Bottlenecks
**Learning:** Using trigonometric functions like `tan`, `atan`, and `cos` inside frequently called GLSL hash functions (e.g. for noise generation like `noised`) creates severe Special Function Unit (SFU) bottlenecks, limiting instruction throughput.
**Action:** Replace trig-based hash functions with pure ALU-based implementations (like Dave Hoskins' method) to maximize performance.
