// trace_denoise.glsl - Denoise buffer write functions

// Write denoise buffers for sky/miss case (no geometry hit)
void writeDenoiseBuffersMiss(uint idx, vec3 rd, vec3 ro, vec3 lightDir, vec3 emissionB, vec3 back, bool inverse_0, bool inverse_1) {
    diffuseIllumiantionBuffer.data[idx].data_swap = init_SH();
    reflectIllumiantionBuffer.data[idx].data_swap = vec3(0);
    refractIllumiantionBuffer.data[idx].data_swap = vec3(0);
    diffuseIllumiantionBuffer.data[idx].normal = vec3(0);
    reflectIllumiantionBuffer.data[idx].normal = infos[0].n;
    refractIllumiantionBuffer.data[idx].normal = vec3(0);
    denoiseBuffer.data[idx].emission = emissionB + back + sampleGodRay(SunLight, MoonLight, ro, rd, 10000, lightDir, true, inverse_1).xyz;
    denoiseBuffer.data[idx].albedo = vec3(1);
    denoiseBuffer.data[idx].albedo2 = vec3(1);
    denoiseBuffer.data[idx].light = vec3(0);
    denoiseBuffer.data[idx].distance = -1;
    denoiseBuffer.data[idx].rd = rd;
    denoiseBuffer.data[idx].absorption = inverse_0 ? vec3(0) : vec3(1);
    denoiseBuffer.data[idx].reflectWeight = 0;
    denoiseBuffer.data[idx].refractWeight = 0;
}

// Initialize denoise buffers after a hit
void initDenoiseBuffersHit(uint idx, vec2 mixWeight) {
    denoiseBuffer.data[idx].reflectWeight = mixWeight.x;
    denoiseBuffer.data[idx].refractWeight = mixWeight.y;
    denoiseBuffer.data[idx].albedo = infos[0].color2;
    denoiseBuffer.data[idx].albedo2 = infos[0].color3;
    denoiseBuffer.data[idx].distance = infos[0].distance;
    denoiseBuffer.data[idx].light = infos[0].surface.light;
    denoiseBuffer.data[idx].macroNormal = infos[0].macroNormal;
    denoiseBuffer.data[idx].illumiantionType = infos[0].type;
    diffuseIllumiantionBuffer.data[idx].data_swap = init_SH();
    reflectIllumiantionBuffer.data[idx].data_swap = vec3(0);
    refractIllumiantionBuffer.data[idx].data_swap = vec3(0);
    diffuseIllumiantionBuffer.data[idx].normal = infos[0].macroNormal;
    diffuseIllumiantionBuffer.data[idx].normal2 = faceforward(infos[0].n, infos[0].n, -infos[0].macroNormal);
    diffuseIllumiantionBuffer.data[idx].pos = infos[0].p;
}

// Handle reflection buffer for smooth surfaces
void handleReflectionBuffer(uint idx, float t) {
    vec3 r_rd, r_ro;
    vec3 r_rd_i = reflect(infos[0].rd_i, infos[0].n);
    
    if (infos[0].surface.R.x <= 0.000125) {
        t = raycast(infos[0].p + infos[0].macroNormal * 0.0001, r_rd_i, r_ro, r_rd, false);
        if (t > -0.5) {
            vec3 reconstructed_pos = infos[0].p + reflect(r_ro - infos[0].p, infos[0].n);
            vec3 reconstructed_normal = reflect(tmp_Payload.material.normal, infos[0].n);
            reflectIllumiantionBuffer.data[idx].normal = t * reconstructed_normal;
            reflectIllumiantionBuffer.data[idx].pos = reconstructed_pos;
        } else {
            reflectIllumiantionBuffer.data[idx].normal = infos[0].distance * r_rd_i;
            reflectIllumiantionBuffer.data[idx].pos = infos[0].p;
        }
    } else {
        reflectIllumiantionBuffer.data[idx].normal = t * r_rd_i;
        reflectIllumiantionBuffer.data[idx].pos = infos[0].p;
    }
    refractIllumiantionBuffer.data[idx].normal = infos[0].n;
    refractIllumiantionBuffer.data[idx].pos = infos[0].p;
}

// Handle refraction buffer for transparent surfaces
void handleRefractionBuffer(uint idx) {
    if (infos[0].surface.R.x <= 0.00125 && infos[0].surface.S.y > 0.001) {
        vec3 r_rd, r_ro;
        float rs = infos[0].n_i == Refractive_Index ? Refractive_Index : 1. / Refractive_Index;
        vec3 refract_rd = refract(infos[0].rd_i, infos[0].n, rs);
        bool refract_ = refract_rd != vec3(0);
        if (!refract_) refract_rd = reflect(infos[0].rd_i, infos[0].n);
        float t = raycast(infos[0].p + (refract_ ? -1 : 1) * infos[0].macroNormal * 0.0001, refract_rd, r_ro, r_rd, false);
        if (t > -0.5) {
            vec3 reconstructed_pos;
            vec3 reconstructed_normal;
            if (refract_) {
                reconstructed_pos = infos[0].p;
                reconstructed_normal = refract(tmp_Payload.material.normal, infos[0].n, rs);
            } else {
                reconstructed_pos = infos[0].p + reflect(r_ro - infos[0].p, infos[0].n);
                reconstructed_normal = reflect(tmp_Payload.material.normal, infos[0].n);
            }
            refractIllumiantionBuffer.data[idx].normal = reconstructed_normal;
            refractIllumiantionBuffer.data[idx].pos = reconstructed_pos;
            diffuseIllumiantionBuffer.data[idx].normal2 = -reconstructed_normal;
        }
    }
}

// Handle smooth surface extra reflection
void handleSmoothSurfaceReflection(uvec2 coord, uint idx, bool hitSmoothSurface, float t, int count) {
    vec3 r_rd_i = reflect(infos[0].rd_i, infos[0].n);
    if (hitSmoothSurface && t < -0.5 && (coord.x % 2 == 1)) {
        vec3 illumiantion2 = vec3(0);
        vec4 rC = rColor(infos[0].surface.Cs, dot(infos[0].microNormal, infos[0].rd_i));
        float IoN = abs(dot(infos[0].n, infos[0].rd_i));
        float OoN = abs(dot(infos[0].n, r_rd_i));
        illumiantion2 = rC.xyz * GGX_G2(IoN, OoN, infos[0].surface.R.x * (1 - infos[0].surface.S.y)) * SampleSky(r_rd_i).xyz;
        if (any(isnan(illumiantion2))) {
            illumiantion2 = vec3(0);
        }
        reflectIllumiantionBuffer.data[idx].data_swap = illumiantion2;
        reflectIllumiantionBuffer.data[getIdx(coord - uvec2(1, 0))].data_swap = illumiantion2;
    }
}

// Write final illumination to appropriate buffer based on type
void writeIlluminationByType(uvec2 coord, uint idx, vec3 illumiantion, bool hitSmoothSurface, int count) {
    switch (infos[0].type) {
        case 0:
            reflectIllumiantionBuffer.data[idx].data_swap = illumiantion;
            break;
        case Diffussion:
            if (coord.x % 2 == 0) {
                SH tmpSH = irradiance_to_SH(illumiantion, infos[0].rd_o);
                diffuseIllumiantionBuffer.data[idx].data_swap = tmpSH;
                diffuseIllumiantionBuffer.data[getIdx(coord + uvec2(1, 0))].data_swap = tmpSH;
            }
            break;
        case Reflection:
            if ((!hitSmoothSurface || count != 0) && coord.x % 2 == 1) {
                illumiantion = clamp(illumiantion, 0, 5 / avgExposure);
                reflectIllumiantionBuffer.data[idx].data_swap = illumiantion;
                reflectIllumiantionBuffer.data[getIdx(coord - uvec2(1, 0))].data_swap = illumiantion;
            }
            break;
        case Refraction:
            if (coord.x % 2 == 0) {
                illumiantion = clamp(illumiantion, 0, 5 / avgExposure);
                refractIllumiantionBuffer.data[idx].data_swap = illumiantion;
                refractIllumiantionBuffer.data[getIdx(coord + uvec2(1, 0))].data_swap = illumiantion;
            }
            break;
        default:
            break;
    }
}

// Finalize denoise buffer with absorption and volumetric lighting
void finalizeDenoiseBuffer(uint idx, vec3 ro, vec3 rd, vec3 lightDir, bool inverse_1, int Volumetric_Light_Samples_) {
    denoiseBuffer.data[idx].absorption = infos[0].absorption;
    denoiseBuffer.data[idx].rd = infos[0].rd_i;

    // Optimization: Take a single volumetric light sample instead of looping,
    // as taking multiple identical samples is redundant for the denoiser pass.
    vec3 sumGodRay = sampleGodRay(SunLight, MoonLight, ro, rd, infos[0].distance, lightDir, true, inverse_1).xyz;
    denoiseBuffer.data[idx].emission = infos[0].emission + sumGodRay;
}
