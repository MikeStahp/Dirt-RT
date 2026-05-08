## 2026-05-08 - Optimize Volumetric Light Sampling in Denoiser Buffer
**Learning:** Taking multiple identical volumetric light samples at the `finalizeDenoiseBuffer` stage is redundant and computationally expensive for the denoiser pass.
**Action:** Replace loop iterations for volumetric light sampling with a single sample to reduce computational overhead without noticeably affecting output quality.
