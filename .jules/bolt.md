## 2024-05-18 - [Optimize GLSL Hash Performance]
**Learning:** Using trigonometric functions like `cos` or `sin` inside frequently called hash functions (e.g., inside 3D noise functions) incurs significant Special Function Unit (SFU) overhead in GLSL. In paths like FBM (fractal Brownian motion), these overheads compound heavily.
**Action:** Always prefer ALU-based hash functions (like Dave Hoskins' `hash11`, `hash12`, etc.) over trig-based hash functions, especially in critical paths.
