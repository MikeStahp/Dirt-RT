// Main ray tracing function

#include "trace_globals.glsl"
#include "trace_denoise.glsl"

vec4 Trace(uvec2 coord, vec3 ro, vec3 rd, vec3 lightDir) {
    uint isEyeInWater = cam.flags & 3u;
    uint idx = getIdx(coord);

    bool inverse_0 = isEyeInWater != 0;
    bool inverse_1 = !inverse_0;
    int count = 0;
    vec3 ro_i = ro, rd_i = rd, ro_o = ro, rd_o = rd;
    vec4 fogA;
    vec3 emissionA, emissionB;
    vec3 absorption = vec3(1);

    vec3 sampleNormal = vec3(0, 1, 0);
    vec3 samplePos = ro;
    float sampleRoughness = 0;

    vec4 fogColor = (isEyeInWater == 2u) ? vec4(0, 0.05, 0.075, 0.1) * 5 : vec4(0, 0.325, 0.295, 0.3);
    vec3 emission = (isEyeInWater == 2u) ? vec3(1, 0.25, 0.05) * 10 : vec3(0);

    vec2 mixWeight = vec2(0);
    bool hitSmoothSurface = false;
    bool hit_diffuse = false;

    // Main ray bounce loop
    for (count = 0; count < MaxRay; count++) {
        fogA = float(inverse_0) * fogColor;
        emissionA = float(inverse_0) * emission;

        float t;
        if (hit_diffuse)
            t = raycast(ro_i, rd_i, ro_o, rd_o, !inverse_0, i16vec2(1001, 0));
        else
            t = raycast(ro_i, rd_i, ro_o, rd_o, !inverse_0);

        if (t < -0.5) {
            infos[count].distance = 1e10;
            break;
        }
        ro_i = ro_o;
        rd_i = rd_o;

        absorption = exp(-(inverse_0 ? t * fogA.yzw : max(b_Q * (b_P.x - ro_i.y) * t - 0.5 * b_Q * t * t * rd_i.y, 0)));

        vec3 normal = faceforward(tmp_Payload.material.normal, tmp_Payload.material.normal, rd_i);
        vec3 macroNormal = faceforward(tmp_Payload.geometryNormal, tmp_Payload.geometryNormal, rd_i);
        
        info A;
        A.p = ro_o;
        vec3 ro_B = ro_o - macroNormal * EPSILON_MIN;
        ro_o += macroNormal * EPSILON_MIN;

        vec4 mA, mB;

        material surface = Material_(ro_o, normal);
        if (surface.R.z > 0.5) {
            vec3 offset = fbm3D(ro_o * 0.125 + time_global * 0.125, 5).yzw * 0.25;
            vec3 dH = normalize(vec3(offset.x, 1, offset.z));
            dH = faceforward(dH, dH, normal);
            normal = normalize(mix(normal, dH, max(0.25 * abs(normal.y), 0)));
        }
        vec3 microNormal;

        microNormal = GGXNormal(normal, surface.R.x, ro_o);

        mA.x = inverse_0 ? Refractive_Index : 1;
        mB.x = inverse_0 ? 1 : Refractive_Index;
        float IoH = dot(rd_i, microNormal);
        vec4 rC = rColor(surface.Cs, IoH);

        float p;
        if (false && count == 0) {
            p = (coord.x % 2) * surface.S.x;
        } else {
            p = rC.w * surface.S.x;
        }
        A.rd_i = rd_i;
        A.n = normal;

        A.n_i = mA.x;
        A.surface = surface;

        A.distance = t;
        A.inside = inverse_0;
        
        bool refract_;
        vec3 I;
        vec3 shade;

        float rs = mA.x / mB.x;
        float F = clamp(fresnel(-rd_i, microNormal, rs), 0, 1);
        bool r = rand(ro_o) < 1 - F;

        float p1 = p + (1 - p) * F * surface.S.y;

        bool b = rand(ro_o) < p;
        A.microNormal = microNormal;
        A.macroNormal = macroNormal;
        A.color2 = surface.Cs;
        A.color3 = surface.Cd;

        if (count == 0) {
            mixWeight.x = p1;
            mixWeight.y = (1 - p1) * (1 - min(F, 1)) * surface.S.y;
        }

        if (b) {
            float IoN = dot(rd_i, normal);
            rd_o = reflect(rd_i, microNormal);
            if (dot(rd_o, normal) > 0) {
                A.n_o = mA.x;
                float OoN = dot(rd_o, normal);
                shade = vec3(GGX_G2(IoN, OoN, surface.R.x) * surface.S.x / (max(p, 0.125) + 1e-5)) * 0.25;
                I = rC.rgb;
                A.sampleRoughness = surface.R.x;
                A.type = Reflection;
            } else
                b = false;
        }
        if (!b) {
            vec3 rd_refract = vec3(0);

            if (r) rd_refract = refract(rd_i, microNormal, rs);

            refract_ = rand(ro_o) < surface.S.y;
            I = surface.Cd;

            vec3 rd_o2;
            if (refract_) {
                A.color2 = surface.Cd;

                float k0 = 1;

                if (r && rd_refract != vec3(0)) {
                    rd_o2 = rd_refract;
                    A.type = Refraction;
                    A.n_o = mB.x;
                    ro_o = ro_B;
                    inverse_0 = !inverse_0;
                } else {
                    rd_o2 = reflect(rd_i, microNormal);
                    A.type = Reflection;
                    A.color3 = surface.Cd;
                    A.n_o = mA.x;
                    k0 = 1;
                }
                A.sampleRoughness = surface.R.x;
                shade = (1 - rC.rgb * surface.S.x) / (1 - p + 1e-3) * k0;
            } else {
                rd_o2 = DiffuseNormal(macroNormal, ro_o);
                A.type = Diffussion;
                A.sampleRoughness = 1;
                A.n_o = mA.x;
                #ifdef Method2
                vec3 b_g0 = vec3(surface.R.w);
                float a0 = -dot(rd_i, rd_o2);
                vec3 b_g1 = b_g0 * b_g0;
                vec3 tmp_x = 1. + b_g1 - 2. * b_g0 * a0;
                tmp_x *= tmp_x * tmp_x;
                vec3 g = 3.0 / 2.0 * (1. + a0 * a0) * (1. - b_g1) / (2. + b_g1) * inversesqrt(tmp_x) / (1 - b_g0);
                shade = (1 - rC.rgb * surface.S.x) / ((max(1 - p, 0.25) + 1e-3) * (abs(dot(rd_i, normal)) + abs(dot(rd_o2, normal)))) * g;
                #else
                shade = (1 - rC.rgb * surface.S.x) / (1 - p + 1e-3);
                #endif
            }
            A.color3 = I;
            rd_o = rd_o2;
            IoH = abs(dot(rd_o, microNormal));
        }

        A.rd_o = rd_o;

        bool change = A.sampleRoughness > sampleRoughness && sampleRoughness < 0.125 || count == 0;
        sampleNormal = change ? normal : sampleNormal;
        samplePos = change ? A.p : samplePos;
        sampleRoughness = change ? A.sampleRoughness : sampleRoughness;

        hitSmoothSurface = hitSmoothSurface || count == 0 && surface.R.x < 0.00125;

        #ifdef Correction
        float correction = A.n_o * IoH / (A.n_i * dot(rd_o, -A.microNormal));
        correction *= correction;
        shade *= correction;
        #endif

        A.color = I;
        A.shade = shade;
        A.absorption = absorption;
        A.emission = (1 - absorption) / (fogA.yzw + 1e-5) * emissionA;
        infos[count] = A;

        // ============================================
        // Russian Roulette - probabilistic path termination
        // Terminates low-energy paths early to save computation
        // Only applies after first few bounces to preserve primary visibility
        // ============================================
        #ifdef RUSSIAN_ROULETTE_DEPTH
        if (count >= RUSSIAN_ROULETTE_DEPTH) {
            // Compute path throughput from accumulated shade
            vec3 throughput = shade * I * absorption;
            float rrProb = russianRouletteProb(throughput);
            
            // Probabilistically terminate path
            if (rand(ro_o + vec3(float(count))) > rrProb) {
                break; // Path terminated
            }
            
            // Boost surviving paths to maintain unbiased estimate
            // This is crucial for energy conservation
            infos[count].shade /= rrProb;
        }
        #endif

        ro_i = ro_o;
        rd_i = rd_o;
    }
    
    // Check if the loop exited because of a miss
    bool isMiss = (count < MaxRay && infos[count].distance > 1e9);

    absorption = exp(-1e10 * fogA.yzw);
    emissionB = (1 - absorption) / (fogA.yzw + 1e-5) * emissionA;

    count -= 1;
    vec3 ro_1, rd_1;
    vec3 c = float(isMiss && count + 1 < MaxRay) * SampleSky(rd_o).xyz * absorption;
    vec3 back = SampleSky(rd_o).xyz * absorption;
    
    // Handle miss case (no geometry hit)
    if (count == -1) {
        writeDenoiseBuffersMiss(idx, rd, ro, lightDir, emissionB, back, inverse_0, inverse_1);
        return vec4(back, -1);
    }

    // Direct lighting sampling
    int j0 = -1, j1 = -1;
    float p_0 = 0, p_1 = 0;
    float A = 0;
    vec3 directLight0[MaxRay];

    vec3 c0 = vec3(1);
    for (int i = 0; i <= count; i++) {
        infos[i].sampleRoughness *= 1;
        A += infos[i].sampleRoughness * infos[i].sampleRoughness;
        directLight0[i] = vec3(0);
        c0 *= infos[i].color;
    }

    float A_0 = A;
    A += 1e-5;
    
    {
        bool a = true;
        bool c0 = true, c1 = true;
        for (int i = count; i >= 0; i--) {
            float sr2 = infos[i].sampleRoughness * infos[i].sampleRoughness;
            float p = sr2 / A;
            float randVal1 = rand(ro_o - rd);
            float randVal2 = rand(ro_o + rd);

            bool b0 = randVal1 < p && c0;
            bool b1 = randVal2 < p && c1;

            if (a && b0) {
                j0 = i;
                p_0 = p;
                c0 = false;
            }

            if (a && b1) {
                j1 = i;
                p_1 = p;
                c1 = false;
            }

            a = c0 || c1;
            A -= float(a) * sr2;
        }
        if (j0 >= 0) {
            vec3 sunL = sampleSunlight(infos[j0].p, infos[j0].n, infos[j0].surface.Cs, infos[j0].surface.Cd, infos[j0].rd_i, infos[j0].surface.S, infos[j0].surface.R,
                    faceforward(lightDir, vec3(0, 1, 0), lightDir), lightDir.y > 0, j0 != 0 ? 0 : infos[0].type, infos[j0].macroNormal, infos[j0].inside);
            // Add RT block light sampling with full PBR BRDF
            vec3 blockL = sampleBlockLight(infos[j0].p, infos[j0].n, infos[j0].surface.Cs, infos[j0].surface.Cd, 
                                           infos[j0].rd_i, infos[j0].surface.S, infos[j0].surface.R, 
                                           infos[j0].macroNormal, infos[j0].inside);
            directLight0[j0] += float(infos[j0].type != Refraction) * (sunL + blockL) / (p_0 + 1e-5);
        }
    }
    
    // Illumination accumulation
    vec3 illumiantion = vec3(0);

    for (int i = count; i >= 0; i--) {
        illumiantion = c * infos[i].shade + (directLight0[i]) / (infos[i].color + 1e-5);
        c = infos[i].absorption * getFogColor(SunLight, MoonLight, infos[i].p, infos[i].rd_i, -lightDir, infos[i].distance * FogS, infos[i].color * (illumiantion + infos[i].surface.light)) + infos[i].emission;
    }

    if (any(isnan(illumiantion))) {
        illumiantion = vec3(0);
    }
    
    illumiantion = clamp(illumiantion, 0, 100 / avgExposure);

    // Write denoise buffers
    initDenoiseBuffersHit(idx, mixWeight);

    float t = infos[0].distance;
    handleReflectionBuffer(idx, t);
    handleRefractionBuffer(idx);
    handleSmoothSurfaceReflection(coord, idx, hitSmoothSurface, t, count);
    writeIlluminationByType(coord, idx, illumiantion, hitSmoothSurface, count);
    finalizeDenoiseBuffer(idx, ro, rd, lightDir, inverse_1, Volumetric_Light_Samples);

    return vec4(illumiantion, infos[0].distance);
}
