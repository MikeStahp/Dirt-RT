
## 2024-05-19 - Avoid Trig Functions (tan, atan, cos) in Noise and Hash Functions
**Learning:** Overusing trigonometric functions (`cos`, `tan`, `atan`) in low-level inner loops like `hash12`, `hash13`, `hash14`, and `hash(float n)` causes severe performance bottlenecks due to Special Function Unit (SFU) starvation. `hash(float)` was called 40 times per `fbm3D` invocation, magnifying the cost.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' methods) over trig-based ones, especially when used within noise functions or raymarching loops. Create aliases (e.g., `hash(float n) -> hash11(n)`) if a legacy API expects it.
