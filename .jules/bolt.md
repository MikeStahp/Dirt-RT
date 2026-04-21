# Bolt's Journal

## 2024-05-18 - Initial Entry
**Learning:** Initializing journal to track codebase-specific performance bottlenecks and learnings.
**Action:** Always check and update this file with critical learnings.

## 2026-04-21 - GLSL Hash Optimization
**Learning:** Found hash functions (hash12, hash13, hash14, hash) in `shaders/lib/common/hash.glsl` using expensive trigonometric functions like `tan`, `atan`, and `cos`. These are computationally heavy and consume Special Function Unit (SFU) bandwidth, causing severe performance bottlenecks in shaders that heavily rely on noise generation (like FBM and water rendering). Dave Hoskins' pure ALU method is standard and much faster.
**Action:** Replace all trig-based hash and noise functions with pure ALU versions (e.g., Dave Hoskins' method) to avoid SFU overhead. Ensure generic aliases like `hash(float)` route to fast ALU implementations (like `hash11`) instead of keeping slow legacy trig versions. Never delete utility functions like `fasthash13` even if redundant; alias them instead.
