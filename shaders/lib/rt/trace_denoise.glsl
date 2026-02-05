// trace_denoise.glsl - Denoise buffer write functions (Disabled for ReSTIR/DLSS prep)

void writeDenoiseBuffersMiss(uint idx, vec3 rd, vec3 ro, vec3 lightDir, vec3 emissionB, vec3 back, bool inverse_0, bool inverse_1) {
    // No-op
}

void initDenoiseBuffersHit(uint idx, vec2 mixWeight) {
    // No-op
}

void handleReflectionBuffer(uint idx, float t) {
    // No-op
}

void handleRefractionBuffer(uint idx) {
    // No-op
}

void handleSmoothSurfaceReflection(uvec2 coord, uint idx, bool hitSmoothSurface, float t, int count) {
    // No-op
}

void writeIlluminationByType(uvec2 coord, uint idx, vec3 illumiantion, bool hitSmoothSurface, int count) {
    // No-op
}

void finalizeDenoiseBuffer(uint idx, vec3 ro, vec3 rd, vec3 lightDir, bool inverse_1, int Volumetric_Light_Samples_) {
    // No-op
}
