## 2026-05-30 - GLSL SFU Overhead from pow(abs(x), -2)
**Learning:** Using pow(abs(x), -2) to calculate inverse squares is a performance anti-pattern in GLSL that compiles to expensive Special Function Unit (SFU) instructions like exp2(-2 * log2(abs(x))).
**Action:** Manually expand inverse square calculations to 1.0 / (x * x) to leverage faster standard ALU multiplication and reciprocal operations, avoiding abs() and pow() completely.
