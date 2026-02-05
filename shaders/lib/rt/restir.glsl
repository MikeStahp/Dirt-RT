#ifndef RESTIR_GLSL
#define RESTIR_GLSL

#include "/lib/buffers/light_data.glsl"
#include "/lib/common.glsl"
#include "/lib/buffers/frame_data.glsl"

// Use the sampler names defined in shaders.properties
// Assuming Set 4 for Custom Textures as per user suggestion
// Defined as rgba32f images for Load/Store operations
layout(set = 4, binding = 0, rgba32f) uniform image2D reservoirA_Sampler;
layout(set = 4, binding = 1, rgba32f) uniform image2D reservoirB_Sampler;

// Uniforms for reprojection
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

const float MAX_HISTORY = 20.0;
const float SPATIAL_RADIUS = 32.0;

// Renamed to avoid conflict with brdf.glsl
struct RestirReservoir {
    float w_sum;      // Sum of weights
    float W;          // Confidence weight (w_sum / (m * pHat))
    float m;          // Number of candidates seen
    uint light_index; // Index of the selected light
};

// Pack/Unpack logic
RestirReservoir unpackReservoir(vec4 data) {
    return RestirReservoir(data.x, data.y, data.z, uint(data.w));
}

vec4 packReservoir(RestirReservoir r) {
    return vec4(r.w_sum, r.W, r.m, float(r.light_index));
}

void initReservoir(out RestirReservoir r) {
    r.w_sum = 0.0;
    r.W = 0.0;
    r.m = 0.0;
    r.light_index = 0;
}

// Target function (unshadowed luminance * geometric term)
float getPHat(vec3 pos, vec3 normal, vec3 lightPos, vec3 lightColor) {
    vec3 L = lightPos - pos;
    float dist2 = dot(L, L);
    float dist = sqrt(dist2);
    L /= dist; // Normalize

    // Geometry term: cos(theta) / dist^2
    float geometry = max(0.0, dot(normal, L)) / max(0.1, dist2);
    float intensity = luma(lightColor);

    return intensity * geometry;
}

// Reprojection Helper
vec2 reproject(vec3 pos) {
    // Transform from current player space to previous clip space
    vec3 worldPos = pos + cameraPosition;
    vec3 prevPlayerPos = worldPos - previousCameraPosition;

    vec4 prevClip = gbufferPreviousProjection * gbufferPreviousModelView * vec4(prevPlayerPos, 1.0);
    vec3 prevNDC = prevClip.xyz / prevClip.w;

    return prevNDC.xy * 0.5 + 0.5;
}

// Streaming Reservoir Sampling Update
bool updateReservoir(inout RestirReservoir r, float w, uint lightIdx, float rnd) {
    r.w_sum += w;
    r.m += 1.0;

    if (r.w_sum <= 0.0) return false;

    if (rnd < (w / r.w_sum)) {
        r.light_index = lightIdx;
        return true;
    }
    return false;
}

// Combine another reservoir into the current one
void combineReservoir(inout RestirReservoir r, RestirReservoir other, float pHat, float rnd) {
    float w = other.W * other.m * pHat;

    r.w_sum += w;
    r.m += other.m;

    if (r.w_sum > 0.0 && rnd < (w / r.w_sum)) {
        r.light_index = other.light_index;
    }
}

// Finalize W calculation
void finalizeReservoir(inout RestirReservoir r, float pHat) {
    if (pHat <= 0.0 || r.m == 0.0) {
        r.W = 0.0;
    } else {
        r.W = r.w_sum / (r.m * pHat);
    }
}

// Clamp sample count to avoid history exploding
void clampReservoir(inout RestirReservoir r, float maxM) {
    if (r.m > maxM) {
        r.w_sum *= maxM / r.m;
        r.m = maxM;
    }
}

// Main ReSTIR Sampling Function
void sampleLightsReSTIR(
    inout vec3 ro, inout vec3 normal,
    out uint bestLightIdx, out float bestLightWeight
) {
    RestirReservoir r;
    initReservoir(r);

    uint lightCount = count; // From LightData SSBO
    if (lightCount == 0) {
        bestLightIdx = 0;
        bestLightWeight = 0.0;
        return;
    }

    // 1. Initial Candidates
    const int M = 4; // Initial candidates count
    for (int i = 0; i < M; i++) {
        uint idx = uint(hash13(vec3(ro * 0.01 + float(i) + float(iFrame)))) * lightCount;
        idx = idx % lightCount; // Safety

        Light l = lights[idx];
        float pHat = getPHat(ro, normal, l.position, l.color);
        float w = pHat * float(lightCount);

        updateReservoir(r, w, idx, getRnd());
    }

    Light survivor = lights[r.light_index];
    float survivorPHat = getPHat(ro, normal, survivor.position, survivor.color);
    finalizeReservoir(r, survivorPHat);
    r.m = 1.0; // Reset M after initial selection

    // 2. Temporal Reuse
    vec2 prevUV = reproject(ro);

    if (prevUV.x >= 0.0 && prevUV.x <= 1.0 && prevUV.y >= 0.0 && prevUV.y <= 1.0) {
        ivec2 dim = ivec2(gl_LaunchSizeEXT.xy);
        ivec2 prevCoord = ivec2(prevUV * vec2(dim));

        bool readFromA = (iFrame % 2 != 0); // If current frame writes to B, read from A
        vec4 prevData;
        if (readFromA) {
            prevData = imageLoad(reservoirA_Sampler, prevCoord);
        } else {
            prevData = imageLoad(reservoirB_Sampler, prevCoord);
        }

        RestirReservoir prevR = unpackReservoir(prevData);
        clampReservoir(prevR, MAX_HISTORY);

        Light prevL = lights[prevR.light_index];
        float prevPHat = getPHat(ro, normal, prevL.position, prevL.color);

        // Combine if valid
        combineReservoir(r, prevR, prevPHat, getRnd());

        survivor = lights[r.light_index];
        survivorPHat = getPHat(ro, normal, survivor.position, survivor.color);
        finalizeReservoir(r, survivorPHat);
    }

    // 3. Spatial Reuse
    ivec2 coord = ivec2(gl_LaunchIDEXT.xy);
    ivec2 dim = ivec2(gl_LaunchSizeEXT.xy);

    ivec2 spatialCenter = (prevUV.x >= 0.0 && prevUV.x <= 1.0 && prevUV.y >= 0.0 && prevUV.y <= 1.0) ? ivec2(prevUV * vec2(dim)) : coord;

    bool readFromA = (iFrame % 2 != 0);

    const int SPATIAL_SAMPLES = 2;
    for (int i = 0; i < SPATIAL_SAMPLES; i++) {
        // Random neighbor
        vec2 offset = vec2(getRnd(), getRnd()) * 2.0 - 1.0;
        offset *= SPATIAL_RADIUS;
        ivec2 neighborCoord = spatialCenter + ivec2(offset);
        neighborCoord = clamp(neighborCoord, ivec2(0), dim - 1);

        vec4 neighborData;
        if (readFromA) {
            neighborData = imageLoad(reservoirA_Sampler, neighborCoord);
        } else {
            neighborData = imageLoad(reservoirB_Sampler, neighborCoord);
        }

        RestirReservoir neighborR = unpackReservoir(neighborData);
        clampReservoir(neighborR, 5.0);

        Light neighborL = lights[neighborR.light_index];
        float neighborPHat = getPHat(ro, normal, neighborL.position, neighborL.color);

        combineReservoir(r, neighborR, neighborPHat, getRnd());
    }

    survivor = lights[r.light_index];
    survivorPHat = getPHat(ro, normal, survivor.position, survivor.color);
    finalizeReservoir(r, survivorPHat);

    // Write Output for next frame (at current coord)
    bool writeToA = (iFrame % 2 == 0);
    if (writeToA) {
        imageStore(reservoirA_Sampler, coord, packReservoir(r));
    } else {
        imageStore(reservoirB_Sampler, coord, packReservoir(r));
    }

    bestLightIdx = r.light_index;
    bestLightWeight = r.W;
}

#endif // RESTIR_GLSL
