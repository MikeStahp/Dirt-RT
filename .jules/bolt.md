## 2026-06-07 - [Trigonometric SFU Overhead in Hash Functions]
**Learning:** Found that hash12, hash13, and hash14 functions were heavily relying on tan and atan functions inside raytracing shaders. These trigger Special Function Unit (SFU) overhead which is very expensive when executed millions of times per frame in GLSL.
**Action:** Replaced trigonometric functions with pure ALU operations (standard Dave Hoskins hash without sine) to significantly reduce overhead.
