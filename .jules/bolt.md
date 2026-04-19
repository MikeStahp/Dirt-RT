## 2026-04-19 - [SFU Bottlenecks in Hash Functions]
**Learning:** [Trigonometric functions (like sin, cos, tan, atan) in inner loop hash functions cause significant Special Function Unit (SFU) bottlenecks on GPUs, drastically reducing shader performance.]
**Action:** [Always prefer Dave Hoskins' ALU-based hash implementations (using fract and dot products) over trigonometric variants for high-frequency operations like noise generation or PRNG initialization.]
