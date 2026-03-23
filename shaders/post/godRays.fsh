#version 430

#include "/lib/buffers/frame_data.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/utils.glsl"
#include "/lib/buffers/denoise.glsl"
#include "/lib/light_color.glsl"

in vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex4;
uniform sampler2D colortex8;
uniform sampler2D colortex9;

/* RENDERTARGETS: 2 */
layout(location = 0) out vec4 fragColor;

void main() {
    /*if(denoiseBuffer.data[getIdx(uvec2(gl_FragCoord.xy))].distance<0){
        return;
    };*/
    float d = sign(denoiseBuffer.data[getIdx(uvec2(gl_FragCoord.xy))].distance);
    const int sampleN = 8;
    // Precomputed weights for exp(-i * i * 0.05) to avoid SFU overhead in loop
    const float[] expWeights = float[](
        0.040762, 0.086294, 0.165299, 0.286505, 0.449329, 0.637628, 0.818731, 0.951229,
        1.000000,
        0.951229, 0.818731, 0.637628, 0.449329, 0.286505, 0.165299, 0.086294, 0.040762
    );
    vec3 sumX = vec3(0);
    float w0 = 0;
    vec2 texSize = textureSize(colortex2, 0);
    const float scale = STEP<=2 ? 3 : 1;
    for (int k = -sampleN; k <= sampleN; k++) {
        int i=k;//int(sign(k)*pow(abs(k),1.25));
        #if STEP==1 || STEP==3
        float w = expWeights[i + sampleN] * float(d == sign(denoiseBuffer.data[getIdx(uvec2(gl_FragCoord.xy+ vec2(i*scale , 0)))].distance)) *
            float(clamp(gl_FragCoord.xy + vec2(i*scale, 0), vec2(0), texSize) == gl_FragCoord.xy + vec2(i*scale , 0));
        sumX += texelFetch(colortex2, ivec2(gl_FragCoord.xy + vec2(i*scale, 0)), 0).xyz * w;
        #else
        float w = expWeights[i + sampleN] * float(d == sign(denoiseBuffer.data[getIdx(uvec2(gl_FragCoord.xy+ vec2(0, i*scale)))].distance)) *
        float(clamp(gl_FragCoord.xy + vec2(0, i*scale), vec2(0), texSize) == gl_FragCoord.xy + vec2(0, i*scale));
        sumX += texelFetch(colortex2, ivec2(gl_FragCoord.xy + vec2(0, i*scale)), 0).xyz * w;
        #endif
        w0 += w;
    }
    sumX /= w0 + 1e-3;
    if (any(isnan(sumX))) sumX = vec3(0);
    fragColor.xyz = sumX;
    #if STEP==4
    denoiseBuffer.data[getIdx(uvec2(gl_FragCoord.xy))].emission=sumX;
    #endif
}
