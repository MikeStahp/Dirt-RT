#ifndef COMMON_TYPES_GLSL
#define COMMON_TYPES_GLSL

struct object {
    float d;
    float d2;
    int id;
    int i_id;
    int s;
};

struct material {
    vec3 Cs;
    vec3 Cd;
    vec2 S;
    vec4 R;
    vec3 light;
};

struct info {
    vec3 rd_i;
    vec3 rd_o;
    vec3 n;
    vec3 microNormal;
    vec3 macroNormal;
    vec3 p;
    material surface;
    float n_i;
    float n_o;
    float distance;
    float sampleDistance;
    vec3 color;
    vec3 color2;
    vec3 color3;
    vec3 shade;
    vec3 absorption;
    vec3 emission;
    float sampleRoughness;
    int type;
    bool inside;
};

#endif // COMMON_TYPES_GLSL
