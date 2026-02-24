## 2024-05-23 - Heavy Trigonometry in Hash Functions
**Learning:** Found heavily obfuscated/inefficient hash functions (fract(tan(dot(...)*atan(...)))) in a shader pack. These operations are extremely expensive on GPUs (SFU usage) compared to standard ALU hashes.
**Action:** Always check utility functions like 'hash' or 'noise' for unnecessary transcendental functions. Use standard, well-tested ALU hashes (like Dave Hoskins') instead.
