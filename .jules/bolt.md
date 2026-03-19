## 2024-05-24 - Pure ALU Hash Functions
**Learning:** In GLSL shaders, especially for noise/FBM, trigonometric functions (`sin`, `cos`, `tan`, `atan`) in hash algorithms become severe performance bottlenecks due to Special Function Unit (SFU) overuse.
**Action:** Always prefer pure ALU-based hash functions (like Dave Hoskins' methods) over ones using trigonometric functions. For example, use `hash11(n)` instead of `fract(cos(n) * 41415.92653)` and remove `tan` and `atan` from 2D/3D hash functions where possible to improve performance.
