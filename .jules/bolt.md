## 2024-05-24 - GLSL SFU Bottlenecks from pow(x, -2)
**Learning:** In GLSL shaders, `pow(x, -2)` is often evaluated using expensive Special Function Unit (SFU) instructions like `exp2(-2 * log2(abs(x)))`, which causes a hidden performance bottleneck.
**Action:** Replace `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` to save ALU instructions and avoid the SFU overhead. Additionally, the `abs()` before squaring is mathematically redundant.
