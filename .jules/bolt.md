## 2026-06-14 - Avoiding pow(x, -2) in GLSL
 **Learning:** In GLSL shaders, `pow(x, -2)` evaluates to `exp2(-2 * log2(abs(x)))`, which causes expensive Special Function Unit (SFU) overhead. Additionally, calculating `abs()` before squaring is mathematically redundant.
 **Action:** Replace `pow(abs(function(x)), -2)` with `1.0 / (val * val)` where `val` is the cached result of `function(x)`. Convert integer literals to float literals (e.g., `1.0`) to ensure proper type safety.
