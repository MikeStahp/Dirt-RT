## 2026-06-06 - GLSL Hash Function Bottleneck
**Learning:** Adding trigonometric operations like `tan` and `atan` to pure mathematical hash functions causes extreme performance degradation on GPUs due to special function unit (SFU) overhead, and provides no measurable improvement to noise quality.
**Action:** Replace all such occurrences with pure ALU operations, strictly adhering to Dave Hoskins' original, math-only hash implementations.
