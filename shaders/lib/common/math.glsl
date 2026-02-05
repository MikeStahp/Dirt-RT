#ifndef COMMON_MATH_GLSL
#define COMMON_MATH_GLSL

// 2D rotation
vec2 rot(vec2 a, float theata) {
    return a.xx * vec2(cos(theata), sin(theata)) + a.yy * vec2(-sin(theata), cos(theata));
}

// 3D rotation by Euler angles
vec3 rot(vec3 a, vec3 range) {
    a.yz = rot(a.yz, range.x);
    a.xz = rot(a.xz, range.y);
    a.xy = rot(a.xy, range.z);
    return a;
}

// 2x2 rotation matrix
mat2 rot(float a) {
    return mat2(cos(a), sin(a), -sin(a), cos(a));
}

// Linear interpolation alternative
float mix2(float A, float B, float x) {
    return (B - A) * x + A;
}

// Complex number multiplication
vec2 cMul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

// Complex number logarithm
vec2 cLog(vec2 a) {
    float b = atan(a.y, a.x);
    if (b < 0.0) b += 2.0 * 3.1415926535;
    return vec2(log(length(a)), b);
}

// Complex number exponential
vec2 cExp(vec2 z) {
    return exp(z.x) * vec2(cos(z.y), sin(z.y));
}

// Complex number power
vec2 cPow(vec2 z, vec2 a) {
    return cExp(cMul(cLog(z), a));
}

// Complex number division
vec2 cDiv(vec2 a, vec2 b) {
    float d = dot(b, b);
    return vec2(dot(a, b), a.y * b.x - a.x * b.y) / d;
}

// Luminance calculation
float luma(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

// Probability mixing
float mixp(float F, float S) {
    return F * S / max(1 + (S - 1) * F, 1e-5);
}

// Correlation index
float R2(float X, float Y, float Z, float XY, float XZ, float YZ, float X2, float Y2, float Z2) {
    float DX = X2 - X * X;
    float DY = Y2 - Y * Y;
    float DZ = Z2 - Z * Z;
    float a0 = X * X * Y2 + Y * Y * X2 - 2 * X * Y * XY;
    float A = a0 * Z * Z + DX * YZ * YZ + DY * XZ * XZ;
    float B = ((-2 * Y2 * X + 2 * XY * Y) * XZ + 2 * (X * XY - X2 * Y) * YZ) * Z + 2 * YZ * (X * Y - XY) * XZ;
    float C = DZ * (a0 + XY * XY - X2 * Y2);
    return 1 + A * B / max(C, 1e-6);
}

#endif // COMMON_MATH_GLSL
