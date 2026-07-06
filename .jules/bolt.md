## 2026-07-06 - Expensive SFU Trigonometry in Hash Functions
 **Learning:** In GLSL shaders, trigonometric operations like `tan` and `atan` inside hash functions cause significant overhead due to Special Function Unit (SFU) evaluations.
 **Action:** Replace these operations with pure ALU alternatives by extracting the fast implementations into new functions and turning the originals into wrappers.
## 2026-07-06 - Expensive Pow Approximations in GLSL
 **Learning:** In GLSL shaders, replacing `pow(abs(x), -2)` with its mathematical equivalent `1.0 / (x * x)` avoids expensive Special Function Unit (SFU) overhead caused by `exp2(-2 * log2(abs(x)))` evaluations while maintaining exactly the same functionality.
 **Action:** Replaced `pow(abs(dot(...)), -2)` calls with their reciprocal squared counterparts by caching the dot product in a local variable to prevent redundant evaluations and optimize ALU usage.
