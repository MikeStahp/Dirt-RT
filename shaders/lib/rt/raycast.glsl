// Raycast functions for ray tracing

Payload tmp_Payload;

float raycast(in vec3 ro, in vec3 rd, out vec3 ro_o, out vec3 rd_o, bool inverse_0, i16vec2 ignore_block_id) {
    payload.wetStrength_global = wetStrength_global;
    payload.wetness_global = wetness_global;
    payload.ignore_block_id = ignore_block_id;
    float tMin = 0;
    float tMax = 2048.0;
    uint rayFlags = 0u;
    payload.inside_block = !inverse_0;
    payload.shadowTransmission = vec3(1);
    payload.prev_distance = 0;
    traceRayEXT(
        acc, // acceleration structure
        rayFlags, // rayFlags
        0xFF, // cullMask
        0, // sbtRecordOffset // <- see comment [1] below
        0, // sbtRecordStride // <- see comment [1] below
        0, // missIndex
        ro, //origin       // ray origin
        tMin, // ray min range
        rd, // ray direction
        tMax, // ray max range
        6 // payload (location = 6)
    );
    Payload hitPayload = payload;

    float t = hitPayload.hitData.w;
    ro_o = hitPayload.hitData.xyz;
    rd_o = rd;
    tmp_Payload = hitPayload;
    return t;
}

float raycast(in vec3 ro, in vec3 rd, out vec3 ro_o, out vec3 rd_o, bool inverse_0) {
    payload.wetStrength_global = wetStrength_global;
    payload.wetness_global = wetness_global;
    payload.ignore_block_id = i16vec2(0);
    float tMin = 0;
    float tMax = 2048.0;
    uint rayFlags = inverse_0 ? gl_RayFlagsCullBackFacingTrianglesEXT : 0u;
    payload.inside_block = !inverse_0;
    payload.shadowTransmission = vec3(1);
    payload.prev_distance = 0;
    traceRayEXT(
        acc, // acceleration structure
        rayFlags, // rayFlags
        0xFF, // cullMask
        0, // sbtRecordOffset // <- see comment [1] below
        0, // sbtRecordStride // <- see comment [1] below
        0, // missIndex
        ro, //origin       // ray origin
        tMin, // ray min range
        rd, // ray direction
        tMax, // ray max range
        6 // payload (location = 6)
    );
    Payload hitPayload = payload;

    float t = hitPayload.hitData.w;
    ro_o = hitPayload.hitData.xyz;
    rd_o = rd;
    tmp_Payload = hitPayload;
    return t;
}
