#ifndef COMMON_BRDF_GLSL
#define COMMON_BRDF_GLSL

#include "/lib/constants.glsl"
#include "/lib/common/math.glsl"
#include "/lib/common/random.glsl"

// Fresnel reflectance color
vec4 rColor(vec3 c, float cosA) {
    vec3 F0 = c + (1.0 - c) * pow(1.0 - abs(cosA), 5.0);
    return vec4(F0, luma(F0));
}

// GGX Lambda function for Smith shadowing
float GGX_Lamda(float VoN, float a) {
    return (-1 + sqrt(1 + a * a * (1. / (VoN * VoN) - 1))) * 0.5;
}

// GGX G2 shadowing-masking function
float GGX_G2(float VoN, float LoN, float a) {
    float L1 = GGX_Lamda(VoN, a);
    float L2 = GGX_Lamda(LoN, a);
    return clamp((1 + L1) / (1 + L2 + L1), 0, 1);
}

// Sample GGX microfacet normal
vec3 GGXNormal(vec3 normal, float roughness, vec3 pos) {
    vec3 randN0;
    randN0.y = -length(normal.xz);
    if (normal.y > 0.99 || normal.y < -0.99)
        randN0.xz = vec2(1, 0);
    else
        randN0.xz = normal.xz * normal.y * inversesqrt(1 - normal.y * normal.y);
    vec3 randN1 = cross(normal, randN0);
    float alpha = rand(pos) * 2 * PI;
    float tmp = rand(pos);
    float cosbeta = min(sqrt(max(0., (1. - tmp) / (1. + tmp * (roughness * roughness - 1.)))), 1.);

    return cosbeta * normal + sqrt(1 - cosbeta * cosbeta) * (cos(alpha) * randN0 + sin(alpha) * randN1);
}

// Sample cosine-weighted hemisphere (diffuse)
vec3 DiffuseNormal(vec3 normal, vec3 pos) {
    vec3 randN0;
    randN0.y = -length(normal.xz);
    if (normal.y > 0.99 || normal.y < -0.99)
        randN0.xz = vec2(1, 0);
    else
        randN0.xz = normal.xz * normal.y * inversesqrt(1 - normal.y * normal.y);
    vec3 randN1 = cross(normal, randN0);
    float alpha = rand(pos) * 2 * PI;
    float tmp = rand(pos);
    return sqrt(1 - tmp) * normal + sqrt(tmp) * (cos(alpha) * randN0 + sin(alpha) * randN1);
}

// GGX distribution function
float GGXdf(float theta, float fai, float a) {
    float a2 = a * a;
    float cos2 = cos(theta);
    cos2 *= cos2;
    return (1 - cos2) / (1 + (2 * a2 - 1) * cos2);
}

// GGX probability density function
float GGXpdf(float costheta, float fai, float a) {
    float a2 = a * a;
    float b = 1 + (a2 - 1) * costheta * costheta;
    return a2 * costheta / (PI * b * b);
}

// Fresnel for dielectrics
float fresnel(vec3 v, vec3 n, float rs) {
    vec2 A;
    A.x = dot(v, n);
    A.y = sqrt(max(1 - (1 - A.x * A.x) * (rs * rs), 0));
    A = (A * rs - A.yx) / max(A * rs + A.yx, 1e-4);
    return 0.5 * dot(A, A);
}

// ============================================
// VNDF (Visible Normal Distribution Function) Sampling
// Better importance sampling for GGX with lower variance
// ============================================

// Sample GGX VNDF - Eric Heitz method
// Produces samples weighted by the visible normal distribution
// Much lower variance than traditional GGX sampling for reflections
vec3 sampleGGX_VNDF(vec3 Ve, float roughness, vec2 xi) {
    float alpha = roughness * roughness;
    
    // Transform view direction to hemisphere configuration
    vec3 Vh = normalize(vec3(alpha * Ve.x, alpha * Ve.y, Ve.z));
    
    // Orthonormal basis around Vh
    float lensq = Vh.x * Vh.x + Vh.y * Vh.y;
    vec3 T1 = lensq > 0.0 ? vec3(-Vh.y, Vh.x, 0.0) * inversesqrt(lensq) : vec3(1.0, 0.0, 0.0);
    vec3 T2 = cross(Vh, T1);
    
    // Sample point with polar coordinates (r, phi)
    float r = sqrt(xi.x);
    float phi = 2.0 * PI * xi.y;
    float t1 = r * cos(phi);
    float t2 = r * sin(phi);
    float s = 0.5 * (1.0 + Vh.z);
    t2 = (1.0 - s) * sqrt(1.0 - t1 * t1) + s * t2;
    
    // Compute normal
    vec3 Nh = t1 * T1 + t2 * T2 + sqrt(max(0.0, 1.0 - t1 * t1 - t2 * t2)) * Vh;
    
    // Transform back to ellipsoid configuration
    return normalize(vec3(alpha * Nh.x, alpha * Nh.y, max(0.0, Nh.z)));
}

// VNDF PDF evaluation
float pdfGGX_VNDF(float NdotH, float NdotV, float roughness) {
    float alpha = roughness * roughness;
    float alpha2 = alpha * alpha;
    
    // GGX D term
    float denom = NdotH * NdotH * (alpha2 - 1.0) + 1.0;
    float D = alpha2 / (PI * denom * denom);
    
    // Smith G1 for masking
    float a = 1.0 / (alpha * sqrt(1.0 / (NdotV * NdotV) - 1.0));
    float G1 = a < 1.6 ? (3.535 * a + 2.181 * a * a) / (1.0 + 2.276 * a + 2.577 * a * a) : 1.0;
    
    return D * G1 * max(0.0, dot(vec3(0, 0, 1), vec3(0, 0, NdotH))) / NdotV;
}

// ============================================
// Multiple Importance Sampling (MIS)
// ============================================

// Power heuristic for MIS (beta = 2)
float misWeightPowerHeuristic(float pdf1, float pdf2) {
    float f = pdf1 * pdf1;
    float g = pdf2 * pdf2;
    return f / max(f + g, 1e-6);
}

// Balance heuristic for MIS
float misWeightBalance(float pdf1, float pdf2) {
    return pdf1 / max(pdf1 + pdf2, 1e-6);
}

// One-sample MIS weight for BRDF + light sampling
// Use when you have 1 BRDF sample and 1 light sample
float misWeight(float pdfBRDF, float pdfLight, int nBRDF, int nLight) {
    float wBRDF = float(nBRDF) * pdfBRDF;
    float wLight = float(nLight) * pdfLight;
    wBRDF *= wBRDF;
    wLight *= wLight;
    return wBRDF / max(wBRDF + wLight, 1e-6);
}

// ============================================
// Reservoir Sampling Structure (ReSTIR Preparation)
// ============================================

struct Reservoir {
    vec3 y;        // Selected sample (light contribution)
    float wSum;    // Sum of weights
    float M;       // Number of candidates seen
    float W;       // Reservoir weight (wSum / (pdf * M))
    float targetPdf; // Target PDF of selected sample
};

Reservoir createReservoir() {
    Reservoir r;
    r.y = vec3(0.0);
    r.wSum = 0.0;
    r.M = 0.0;
    r.W = 0.0;
    r.targetPdf = 0.0;
    return r;
}

// Update reservoir with a new sample (streaming RIS)
bool updateReservoir(inout Reservoir r, vec3 contribution, float weight, float targetPdf, float rnd) {
    r.wSum += weight;
    r.M += 1.0;
    
    if (rnd * r.wSum < weight) {
        r.y = contribution;
        r.targetPdf = targetPdf;
        return true;
    }
    return false;
}

// Finalize reservoir to get final contribution
vec3 finalizeReservoir(Reservoir r) {
    if (r.M < 1.0 || r.targetPdf < 1e-6) return vec3(0.0);
    r.W = r.wSum / (r.targetPdf * r.M);
    return r.y * r.W;
}

// Combine two reservoirs (for spatial/temporal reuse in ReSTIR)
void combineReservoirs(inout Reservoir r1, Reservoir r2, float targetPdf2, float rnd) {
    float weight = r2.W * r2.M * targetPdf2;
    r1.M += r2.M;
    r1.wSum += weight;
    
    if (rnd * r1.wSum < weight) {
        r1.y = r2.y;
        r1.targetPdf = targetPdf2;
    }
}

#endif // COMMON_BRDF_GLSL
