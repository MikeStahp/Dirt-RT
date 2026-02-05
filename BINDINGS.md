# Shader Bindings Analysis

This document details the bindings for the shaders involved in the rendering and composition pipeline, specifically focusing on the final composition stage as requested ("los que compongan la imagen al final").

## 1. Final Composition Shader (`shaders/composite92.fsh`)

This shader appears to be the primary "final" compositor, applying tone mapping and mixing the ray-traced scene with other elements (entities). It includes `shaders/post/final.fsh`.

### Bindings
* **Storage Buffers (SSBO):**
  * `frameData` (Binding 1, Set 3): Contains global frame information (exposure, sunlight, time, etc.).
* **Texture Samplers (Uniforms):**
  * `colortex0`: Main color buffer (likely containing the denoised/accumulated scene).
  * `colortex1`, `colortex2`, `colortex4`, `colortex5`: Auxiliary buffers.
  * `colortex7`: Entity color buffer.
  * `colortex8`: Mask/Data buffer (used for depth/mask comparison).
  * `colortex9`: Mask/Data buffer.
  * `depthtex0`: Depth buffer.
* **Uniforms:**
  * `near`, `far`: Camera clipping planes.
  * `gbuffersProjectionInverse`, `gbuffersModelViewInverse`, `cameraPosition`: standard transformation matrices (from `final.vsh`).
* **Outputs (Render Targets):**
  * Location 0: `fragColor` (writes to `colortex0`)
  * Location 1: `fragData` (writes to `colortex8`)
  * Location 2: `fragData2` (writes to `colortex9`)

---

## 2. Ray Generation Shader (`shaders/ray0.rgen`)

This shader initiates the path tracing process and generates the raw image data.

### Bindings
* **Uniform Buffers (UBO):**
  * `CameraInfo` (Binding 0): Camera matrices, position, and flags.
* **Acceleration Structures:**
  * `acc` (Binding 1): The ray tracing acceleration structure (TLAS).
* **Texture Samplers:**
  * `blockTex` (Binding 3): Block texture atlas.
* **Storage Images:**
  * `RayTraceData` (Binding 6): The output image for the ray tracing pass.
  * `diffuseIllumiantionData_*`: Various images for SH data, normals, positions (defined in `lib/buffers/denoise.glsl`).
  * `reflectIllumiantionData_*`: Reflection data images.
  * `refractIllumiantionData_*`: Refraction data images.
* **Storage Buffers (SSBO):**
  * `DenoiseBuffer` (Binding 0, Set 3): Denoising data.
  * `frameData` (Binding 1, Set 3): Frame data.
  * `DiffuseIllumiantionDataBuffer` (Binding 2, Set 3).
  * `ReflectIllumiantionDataBuffer` (Binding 3, Set 3).
  * `RefractIllumiantionDataBuffer` (Binding 4, Set 3).

---

## 3. Denoising/Accumulation Shader (`shaders/composite.fsh`)

This shader (via `shaders/post/100.glsl`) processes the raw ray tracing output, performing temporal accumulation and denoising.

### Bindings
* **Storage Buffers (SSBO):**
  * `DenoiseBuffer` (Binding 0, Set 3): Read/Write access for history and variance.
  * `DiffuseIllumiantionDataBuffer` (Binding 2, Set 3).
  * `frameData` (Binding 1, Set 3).
* **Storage Images:**
  * `extInfoBuffer`: Writes weight and variance information.
  * `diffuseIllumiantionData_*`: Writes updated SH data.
* **Texture Samplers:**
  * `colortex0`: Input color/data.
  * `depthtex0`: Depth buffer for reprojection.
* **Uniforms:**
  * Matrices for reprojection (`gbuffersProjectionInverse`, `gbuffersPreviousModelView`, etc.).
