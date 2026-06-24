## 2026-06-24 - Pow SFU Overhead Optimization
**Learning:** In GLSL, evaluating pow(abs(x), -2) introduces expensive Special Function Unit (SFU) overhead, and the abs() operation is mathematically redundant before squaring.
**Action:** Replace pow(abs(x), -2) with its reciprocal square equivalent 1.0 / (x * x) and store the inner expression in a local variable to prevent redundant evaluations.
