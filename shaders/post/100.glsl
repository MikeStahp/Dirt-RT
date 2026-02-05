#version 430 compatibility

#include "/lib/constants.glsl"
#include "/lib/buffers/frame_data.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/utils.glsl"

uniform sampler2D colortex0; // Input from Ray Tracing (RayTraceData)
uniform vec2 resolution;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 output_data;

void main() {
    vec2 texCoord = gl_FragCoord.xy / resolution;
    vec4 traceData = texture(colortex0, texCoord);
    
    // Pass through the color.
    // Trace data is (R, G, B, Distance).
    // We output (R, G, B, 1.0) for display, or keep distance if needed for next stages.
    output_data = vec4(traceData.rgb, 1.0);
}
