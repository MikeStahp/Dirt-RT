// Lighting and sampling functions

vec4 sampleGodRay(vec3 b_Sun, vec3 b_Moon, vec3 ro, vec3 rd, float far, vec3 lightDir, bool hitFace, bool inside) {
    #if Sharp_Volumetric_Light
    vec3 sampleDir = lightDir;
    #else
    vec3 X, Y, Z;
    XYZ(lightDir, X, Y, Z);
    float r1 = getRnd();
    float alpha = getRnd() * 2 * PI;
    float cosbeta = (1 - r1 * (1 - cosD_S));

    vec3 ro_o, rd_o;

    vec3 sampleDir = cosbeta * Y + sqrt(1 - cosbeta * cosbeta) * (cos(alpha) * X + sin(alpha) * Z);
    #endif

    if (isDarkened || sampleDir.y > 0) return vec4(0, 0, 0, 1e10);
    float rnd = getRnd();
    float h = b_P.x - ro.y;
    vec3 q = vec3(0.00000025);
    vec3 log_rnd = 2 * log(rnd) / q;
    float sampleX = luma(abs(log_rnd / (h + sqrt(max(vec3(0), h * h + log_rnd * rd.y)))));
    vec3 c = vec3(0);
    float s = min(far - 0.01, sampleX);
    vec3 samplePos = ro + s * rd;
    float t = 1;
    if (sampleX > far) {
        c = 0 * float(!hitFace) * getSkyColor(b_Sun, b_Moon, samplePos, rd, -lightDir);
    } else {
        vec3 rd1, ro1;
        t = raycast(samplePos, -sampleDir, ro1, rd1, inside, i16vec2(1001, 0));
        float dot_rd_lightDir = dot(rd, lightDir);
        vec3 b_g0_2 = b_g0 * b_g0;
        vec3 tmp_0 = 1. + b_g0_2 + 2. * b_g0 * dot_rd_lightDir;
        tmp_0 *= tmp_0 * tmp_0;
        vec3 g = 3. / (8. * PI) * (1. + dot_rd_lightDir * dot_rd_lightDir) * (1. - b_g0_2) / (2. + b_g0_2) * inversesqrt(tmp_0);
        c = float(t < -0.5) * g * SampleSky(-sampleDir);
    }

    c *= tmp_Payload.shadowTransmission * max(0.5*sqrt(1-cosD_S*cosD_S) * 0.25 * (1 - 0.5 * clamp(-lightDir.y * 2, 0, 1)), rainStrength_global * 0.125) * exp(-b_Q * h * sampleX + 0.5 * b_Q * sampleX * sampleX * sampleDir.y);
    return vec4(clamp(c, 0, 10), t < -0.5 ? s : -1);
}


vec3 sampleSunlight(vec3 ro, vec3 normal, vec3 Cs, vec3 Cd, vec3 rd_i, vec2 S, vec4 R, vec3 lightDir, bool night, int type /*,int inwater*/ , vec3 marcoNormal, bool inside) {
    ro += (dot(lightDir, marcoNormal) > 0.15 ? lightDir : marcoNormal) * 0.01; // (lightDir+normal) * 0.01;

    //return vec3(max(0,dot(lightDir,marcoNormal)),max(0,-dot(lightDir,marcoNormal)),0);

    vec3 X, Y, Z;
    XYZ(lightDir, X, Y, Z);
    vec3 ro_o, rd_o;

    // ⚡ Bolt: randFloat() provides faster uniform random numbers than rand(vec3)
    float r1 = randFloat();
    float alpha = randFloat() * 2 * PI;
    float cosbeta = 1 - r1 * (1 - cosD_S);
    vec3 sampleDir = cosbeta * Y + sqrt(1 - cosbeta * cosbeta) * (cos(alpha) * X + sin(alpha) * Z);

    float t = raycast(ro, -sampleDir, ro_o, rd_o, !inside, i16vec2(1001, 0));
    if (t > -0.5) {
        return vec3(0);
    }
    vec3 sunlight = SampleSky(-sampleDir).xyz;

    XYZ(normal, X, Y, Z);
    vec3 microNormal = -normalize(sampleDir + rd_i);

    vec4 rC = rColor(Cs, dot(microNormal, -rd_i));
    float OoN = dot(-normal, sampleDir);
    float IoH = abs(dot(microNormal, rd_i));
    float weightA = GGXpdf(clamp(dot(microNormal, Y), 0, 1), 0, R.x);
    weightA *= GGX_G2(dot(normal, rd_i), abs(OoN), R.x);

    vec3 sampleColor = vec3(0);

    #ifdef Method2
    vec3 b_g0 = vec3(R.w);
    float a0 = dot(rd_i, sampleDir);
    vec3 b_g1 = b_g0 * b_g0;
    vec3 tmp_x = 1. + b_g1 + 2. * b_g0 * a0;
    tmp_x *= tmp_x * tmp_x;
    vec3 g = 1.5 / PI * (1. + a0 * a0) * (1. - b_g1) / (2. + b_g1) * inversesqrt(tmp_x) / (1-b_g0);
    #endif

    switch (type) {
        case 0:
        #ifdef Method2
        sampleColor = (weightA * Cs * rC.xyz * S.x * 0.25 / IoH
                + Cd * (1 - S.x * rC.xyz) / (max(-OoN, 0) + abs(dot(normal, rd_i)) + 0.001) * g) * max(OoN, 0);
        #else
        sampleColor = (weightA * Cs * rC.xyz * S.x * 0.25 / IoH
                + Cd * (1 - S.x * rC.xyz)) * max(OoN, 0);
        #endif
        break;
        case Diffussion:
        #ifdef Method2
        sampleColor = Cd * max(OoN, 0) / (max(OoN, 0) + max(dot(normal, -rd_i), 0) + 0.001) * g;
        #else
        sampleColor = Cd * max(OoN, 0);
        #endif

        break;
        case Reflection:
        sampleColor = (weightA * Cs * 0.25 / IoH) * max(OoN, 0);
        break;
        default:
        break;
    }
    sampleColor *= sunlight * tmp_Payload.shadowTransmission * sqrt(1-cosD_S*cosD_S)*10;
    return max(vec3(0), vec3(sampleColor) * (dot(sampleDir, lightDir) > cosD_S ? 1 : 0));
}

// Sample block light with improved sampling
// Uses low-discrepancy sequences for better coverage without more rays
// Foundation for future ReSTIR temporal/spatial reuse
vec3 sampleBlockLight(vec3 ro, vec3 normal, vec3 Cs, vec3 Cd, vec3 rd_i, 
                      vec2 S, vec4 R, vec3 macroNormal, bool inside) {
    float roughness = max(R.x, 0.04);
    float metallic = 1.0 - S.x;
    
    vec3 rayOrigin = ro + macroNormal * 0.02;
    vec3 totalContrib = vec3(0.0);
    float totalWeight = 0.0;
    
    vec3 V = -rd_i;
    float NdotV = max(dot(normal, V), 0.001);
    
    for (int i = 0; i < BLOCKLIGHT_SAMPLES; i++) {
        // Use low-discrepancy sampling for better coverage
        vec2 xi = R2Sequence(uint(i) + iFrame * uint(BLOCKLIGHT_SAMPLES));
        xi = temporalJitter(xi, iFrame);
        
        // Cosine-weighted hemisphere sampling
        vec3 sampleDir = DiffuseNormal(macroNormal, rayOrigin + vec3(float(i)));
        
        vec3 ro_o, rd_o;
        float t = raycast(rayOrigin, sampleDir, ro_o, rd_o, !inside, i16vec2(1001, 0));
        
        if (t < 0.0 || t > BLOCKLIGHT_MAX_DISTANCE) continue;
        
        vec3 hitEmission = tmp_Payload.material.emission;
        float emissionLuma = dot(hitEmission, vec3(0.299, 0.587, 0.114));
        if (emissionLuma < 0.001) continue;
        
        // Physical attenuation
        float dist2 = t * t;
        float attenuation = 1.0 / (1.0 + dist2 * BLOCKLIGHT_FALLOFF);
        
        // BRDF evaluation
        float NdotL = max(dot(normal, sampleDir), 0.0);
        vec3 H = normalize(V + sampleDir);
        float NdotH = max(dot(normal, H), 0.0);
        float VdotH = max(dot(V, H), 0.0);
        
        // Diffuse (Lambert)
        vec3 diffuse = Cd * (1.0 - metallic) * (1.0 / PI);
        
        // Specular (GGX)
        vec3 specular = vec3(0.0);
        if (S.x > 0.001 && NdotL > 0.0) {
            vec4 F = rColor(Cs, VdotH);
            float D = GGXpdf(NdotH, 0.0, roughness);
            float G = GGX_G2(NdotV, NdotL, roughness);
            specular = F.rgb * D * G / (4.0 * NdotV + 0.001);
        }
        
        vec3 brdf = diffuse + specular * S.x;
        // Unbiased estimate using Importance Sampling (cosine-weighted)
        // Contribution = (BRDF * L * NdotL * Atten) / (NdotL / PI) = BRDF * L * PI * Atten
        vec3 sampleContrib = brdf * hitEmission * PI * attenuation * EMISSION_SCALE;
        
        totalContrib += sampleContrib;
    }
    
    // Simple unbiased average of samples
    return BLOCKLIGHT_SAMPLES > 0 ? max(vec3(0.0), totalContrib / float(BLOCKLIGHT_SAMPLES)) : vec3(0.0);
}
