## 2026-06-30 - Avoiding SFU overhead by rewriting negative powers
 **Learning:** In GLSL shaders, using pow(x, -2) evaluates to exp2(-2 * log2(abs(x))) which relies heavily on expensive Special Function Units (SFUs). Also, mathematical properties mean that 1.0 / (x * x) safely handles division by zero as both mathematically yield infinity without needing an epsilon mitigation.
 **Action:** When squaring values for a denominator, use 1.0 / (x * x) instead of pow(x, -2), and precompute any repeated dot products into local variables before squaring to prevent redundant evaluations.
