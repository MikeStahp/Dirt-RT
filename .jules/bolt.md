## 2026-05-11 - Precomputing GLSL Transcendental Constants
**Learning:** Found multiple instances of `pow(vec3, vec3)` with constant arguments being executed at runtime for Rayleigh scattering calculation. In GLSL, this requires the Special Function Unit (SFU) and introduces unnecessary overhead, especially for variables initialized multiple times per frame.
**Action:** Precompute these static vectors via CPU/external scripts and hardcode them as `const vec3` literals in GLSL code to avoid runtime evaluation entirely while preserving the mathematical precision.
