#ifndef LIGHT_DATA_GLSL
#define LIGHT_DATA_GLSL

struct Light {
    vec3 position; // World space coordinates (center of block)
    float radius;  // Light radius (approx. block luminance level)
    vec3 color;    // RGB color (linear)
    uint type;     // 0 = Block Light, 1 = Sun/Sky Light
};

layout(std430, set = 3, binding = 10) buffer LightData {
    uint count;       // Total number of active lights
    uint _pad1;       // Padding for alignment
    uint _pad2;
    uint _pad3;
    Light lights[];   // Array of lights
};

#endif // LIGHT_DATA_GLSL
