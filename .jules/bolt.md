## 2026-06-26 - GLSL SFU vs ALU Overhead
 **Learning:** In GLSL shaders, replacing `pow(x, -2)` with its mathematical equivalent `1.0 / (x * x)` avoids expensive Special Function Unit (SFU) overhead caused by `exp2(-2 * log2(abs(x)))` evaluations and redundant `abs()` operations, making it much faster using pure ALU instructions.
 **Action:** Always look for inverse power operations and replace them with explicitly computed reciprocal squares and float literals to improve performance while maintaining mathematical correctness and type safety.
