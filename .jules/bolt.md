## 2024-05-23 - Redundant Array Initialization in Shaders
**Learning:** GLSL compilers may not optimize away explicit loop initializations for local arrays (like `infos[MaxRay]`) even if they are overwritten. In ray tracing loops, initializing per-ray data is costly (O(N) operations per pixel). It's better to set values (like distance=1e10) only on the specific exit paths (misses) or overwrite them on hits.
**Action:** Check all fixed-size array usage in shaders for redundant initialization loops, especially in hot paths like `Trace`.
