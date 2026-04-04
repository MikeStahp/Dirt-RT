## 2024-05-24 - Optimizing the hash(float) Function
**Learning:** Using trigonometric functions like `cos` inside simple hash functions causes a significant bottleneck when called repetitively (e.g., 8 times per call in `noised`). This occurs because trigonometric operations require expensive Special Function Unit (SFU) usage.
**Action:** Use ALU-based alternatives (like Dave Hoskins' hash methods, e.g., `hash11`) for generic hash utilities to dramatically reduce rendering latency, especially for heavy tasks like FBM rendering which heavily relies on `noised`.
