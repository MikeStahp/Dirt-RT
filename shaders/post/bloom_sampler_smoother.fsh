#version 430
#include "/lib/common.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/utils.glsl"
in vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
/*
const int colortex1Format = RGBA32F;
*/
/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 bloomColor;
void main() {
    fragColor = texture(colortex0, texCoord);
    //return;
    #ifdef FINAL
    vec3 avg = vec3(0);
    for (int i = -2; i <= 2; i++)
        for (int j = -2; j <= 2; j++)
            avg += texelFetch(colortex1, ivec2(gl_FragCoord.xy + vec2(i, j)), 0).rgb;
    fragColor.xyz = mix(avg/25,texture(colortex0, texCoord).rgb,0.875);

    fragColor.xyz = pow(ACESFilm(fragColor.xyz),vec3(1/2.2));
    bloomColor = texture(colortex1, texCoord);
    if (any(isnan(fragColor.xyz))) fragColor.xyz = vec3(0);
    return;
    #else
    const int sampleN = 12;
    // Precomputed weights for exp(-i * i * 0.025) to avoid SFU overhead in loop
    const float[] expWeights = float[](
        0.027324, 0.048558, 0.082085, 0.131994, 0.201897, 0.293758, 0.406570, 0.535261, 0.670320, 0.798516, 0.904837, 0.975310,
        1.000000,
        0.975310, 0.904837, 0.798516, 0.670320, 0.535261, 0.406570, 0.293758, 0.201897, 0.131994, 0.082085, 0.048558, 0.027324
    );
    vec3 sumX = vec3(0);
    float w0 = 0;
    vec2 texSize = textureSize(colortex0, 0);
    for (int i = -sampleN; i <= sampleN; i++) {
        
        #if STEP==1
        float w = expWeights[i + sampleN];
        w *= float(clamp(gl_FragCoord.xy + vec2(i * 5, 0), vec2(0), texSize) == gl_FragCoord.xy + vec2(i * 5, 0));
        sumX += texelFetch(colortex1, ivec2(gl_FragCoord.xy + vec2(i * 5, 0)), 0).xyz * w;
        #else
        float w = expWeights[i + sampleN];
        w *= float(clamp(gl_FragCoord.xy + vec2(0, i * 5), vec2(0), texSize) == gl_FragCoord.xy + vec2(0, i * 5));
        sumX += texelFetch(colortex1, ivec2(gl_FragCoord.xy + vec2(0, i * 5)), 0).xyz * w;
        #endif
        w0 += w;
    }
    sumX /= w0 + 1e-3;
    if (any(isnan(sumX))) sumX = vec3(0);
    bloomColor.xyz = sumX;
    #endif
}
