#ifndef COMMON_RANDOM_GLSL
#define COMMON_RANDOM_GLSL

#include "/lib/constants.glsl"

uint iFrame = 0;

// Wang hash for random number generation
uint wseed;
uint whash(uint seed)
{
    seed = (seed ^ uint(61)) ^ (seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> uint(4));
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> uint(15));
    return seed;
}

float randcore4()
{
    wseed = whash(wseed);
    return float(wseed) * (1.0 / 4294967296.0);
}

// Build orthonormal basis from normal
void XYZ(vec3 n, out vec3 X, out vec3 Y, out vec3 Z) {
    Y = n;
    X = vec3(n.z, 0, n.x);
    X = abs(n.y) == 1 ? vec3(1, 0, 0) : normalize(X);
    Z = cross(n, X);
}

float rand_i = 0.;

float rand(vec3 p3)
{
    p3 *= 31;
    rand_i += 0.4;
    p3 += rand_i + iFrame;
    p3 = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

float rand(vec2 p)
{
    rand_i += 0.4;
    p += rand_i + iFrame;
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// 3-component Wang hash
uvec3 wseed3;
uvec3 whash3(uvec3 seed)
{
    seed = (seed ^ uint(61)) ^ (seed >> uvec3(16));
    seed *= uvec3(9);
    seed = seed ^ (seed >> uvec3(4));
    seed *= uvec3(0x27d4eb2d);
    seed = seed ^ (seed >> uvec3(15));
    return seed;
}

float getRnd() {
    wseed3 = whash3(wseed3.yzx);
    return fract(float(wseed3.x) * (1.0 / 4294967296.0));
}

// Random sphere direction
vec3 rndS(vec3 pos) {
    return normalize(tan(vec3(rand(pos) - 0.5, rand(pos) - 0.5, rand(pos) - 0.5)));
}

// Simple random (alternative, used in noise functions)
float random_(vec3 st) {
    return fract(sin(dot(st.xyz, vec3(12.9898,78.233,45.1642))) * 43758.5453);
}

// ============================================
// Blue Noise & Low-Discrepancy Sampling (ReSTIR Ready)
// ============================================

// R2 sequence - quasi-random with good 2D distribution
// Better than pure random, zero texture cost
const float GOLDEN_RATIO = 1.6180339887;
const float PLASTIC_CONST = 1.324717957; // 1D plastic constant

vec2 R2Sequence(uint n) {
    // Generalized golden ratio for 2D
    const float g = 1.32471795724; // Cubic root plastic constant  
    const float a1 = 1.0 / g;
    const float a2 = 1.0 / (g * g);
    return fract(vec2(0.5) + float(n) * vec2(a1, a2));
}

// Cranley-Patterson rotation for temporal jittering
// Rotates the entire sequence frame-to-frame for TAA compatibility
vec2 temporalJitter(vec2 sample2D, uint frameIndex) {
    float jitter = fract(float(frameIndex) * GOLDEN_RATIO);
    return fract(sample2D + jitter);
}

// Improved Sobol sequence (dimension 0 and 1)
// Better low-discrepancy than hash-based random
uint sobolDirection0[32] = uint[32](
    0x80000000u, 0x40000000u, 0x20000000u, 0x10000000u,
    0x08000000u, 0x04000000u, 0x02000000u, 0x01000000u,
    0x00800000u, 0x00400000u, 0x00200000u, 0x00100000u,
    0x00080000u, 0x00040000u, 0x00020000u, 0x00010000u,
    0x00008000u, 0x00004000u, 0x00002000u, 0x00001000u,
    0x00000800u, 0x00000400u, 0x00000200u, 0x00000100u,
    0x00000080u, 0x00000040u, 0x00000020u, 0x00000010u,
    0x00000008u, 0x00000004u, 0x00000002u, 0x00000001u
);

uint sobolDirection1[32] = uint[32](
    0x80000000u, 0xC0000000u, 0xA0000000u, 0xF0000000u,
    0x88000000u, 0xCC000000u, 0xAA000000u, 0xFF000000u,
    0x80800000u, 0xC0C00000u, 0xA0A00000u, 0xF0F00000u,
    0x88880000u, 0xCCCC0000u, 0xAAAA0000u, 0xFFFF0000u,
    0x80008000u, 0xC000C000u, 0xA000A000u, 0xF000F000u,
    0x88008800u, 0xCC00CC00u, 0xAA00AA00u, 0xFF00FF00u,
    0x80808080u, 0xC0C0C0C0u, 0xA0A0A0A0u, 0xF0F0F0F0u,
    0x88888888u, 0xCCCCCCCCu, 0xAAAAAAAAu, 0xFFFFFFFFu
);

float sobolSample(uint index, uint dim) {
    uint result = 0u;
    uint i = index;
    for (int bit = 0; bit < 32 && i != 0u; bit++) {
        if ((i & 1u) != 0u) {
            result ^= (dim == 0u) ? sobolDirection0[bit] : sobolDirection1[bit];
        }
        i >>= 1u;
    }
    return float(result) * (1.0 / 4294967296.0);
}

vec2 sobolSample2D(uint index) {
    return vec2(sobolSample(index, 0u), sobolSample(index, 1u));
}

// Blue noise approximation via interleaved gradient noise
// Very cheap, good for screen-space sampling
float interleavedGradientNoise(vec2 coord) {
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(coord, magic.xy)));
}

// Temporal blue noise - correlates across frames for TAA
float temporalBlueNoise(vec2 coord, uint frame) {
    float noise = interleavedGradientNoise(coord);
    float temporal = fract(float(frame) * GOLDEN_RATIO);
    return fract(noise + temporal);
}

vec2 temporalBlueNoise2D(vec2 coord, uint frame) {
    return vec2(
        temporalBlueNoise(coord, frame),
        temporalBlueNoise(coord + vec2(17.0, 31.0), frame)
    );
}

// Stratified sampling helper - divides unit square
vec2 stratifiedSample(uint sampleIndex, uint totalSamples, vec2 jitter) {
    uint sqrtN = uint(sqrt(float(totalSamples)));
    uint x = sampleIndex % sqrtN;
    uint y = sampleIndex / sqrtN;
    return (vec2(float(x), float(y)) + jitter) / float(sqrtN);
}

// Russian Roulette probability based on throughput
float russianRouletteProb(vec3 throughput) {
    return clamp(max(throughput.r, max(throughput.g, throughput.b)), 0.05, 1.0);
}

#endif // COMMON_RANDOM_GLSL
