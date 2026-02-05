// trace_globals.glsl - Global variables for ray tracing

vec3 originalPos = vec3(0);

info infos[MaxRay + 1];

//#define EnableObjectLight

#ifdef EnableObjectLight
vec4 centers[1] = { { 0, 0, 0, 1 } };
int ids[1] = { 7 };
#endif
