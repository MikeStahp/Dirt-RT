## 2026-05-03 - Pure ALU Hash Functions
**Learning:** In GLSL, trigonometric functions like `tan`, `atan`, and `cos` are executed on the Special Function Units (SFU), which are limited in number per Streaming Multiprocessor compared to regular ALUs. Using them in high-frequency functions like noise generation (`hash12`, `hash13`, `hash14`, `hash`) creates severe bottlenecks.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' method) over those relying on trigonometric operations to ensure maximum throughput in shader code.
