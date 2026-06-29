## $(date +%Y-%m-%d) - GLSL reciprocal square optimizations

**Learning:** GLSL `pow()` calls with negative exponents are extremely expensive. Expressions like `pow(abs(x), -2)` get expanded to `exp2(-2 * log2(abs(x)))`, engaging Special Function Units (SFUs). We can avoid this entirely since squaring effectively makes the base positive anyway, and mathematically `x^-2 == 1 / x^2`.
**Action:** Replace `pow(abs(x), -2)` with `1.0 / (x * x)` to stick to pure ALU operations. Also make sure to save the inner dot product first to avoid re-evaluating it when calculating the square for the denominator.
