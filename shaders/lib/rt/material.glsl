// Material construction functions

material newMaterial(vec3 Cs, vec3 Cd, vec2 S, vec4 R, vec3 light) {
    material a;
    a.Cs = Cs;
    a.Cd = Cd;
    a.S = S;
    a.R = R;
    a.light = light;
    return a;
}

material Material_(vec3 pos, vec3 nor) {
    vec3 albedo = tmp_Payload.material.albedo * (1 - tmp_Payload.material.ambientOcclusion);
    bool water = tmp_Payload.material.block_id.x == 1000;
    float trans = float(!water && 0.9 < tmp_Payload.material.translucent && tmp_Payload.material.block_id.x != 1001);
    trans = tmp_Payload.material.block_id.x == 1002 ? 0.25 : trans;
    float roughness = water ? 0 : tmp_Payload.material.roughness;
    roughness = tmp_Payload.material.block_id.x == 1002 ? 0 : roughness;
    albedo = water ? vec3(1) : albedo;
    
    // Emission handling with configurable scale
    vec3 emission = tmp_Payload.material.emission;
    emission = tmp_Payload.material.block_id.x == 1002 ? albedo * (1 - trans) : emission;
    emission *= EMISSION_SCALE; // Use configurable scale instead of hardcoded value
    
    // SSS from LabPBR material
    float sss = tmp_Payload.material.subsurface_scattering;
    
    return newMaterial(
        clamp(tmp_Payload.material.F0, 0, 1), 
        albedo, 
        vec2((1 - tmp_Payload.material.metallic) * trans, 1 - trans), 
        vec4(roughness > 0.01 ? max(roughness, 0.0125) : 0, trans, water, sss), 
        emission
    );
}
