## 2024-05-24 - [Avoid Trig in Hash]
**Learning:** Avoid `cos` in GLSL `hash(float)` functions because it's slow (SFU overhead).
**Action:** Replace `hash(float)` implementations using trig with ALU-based functions like `hash11(n)`.
