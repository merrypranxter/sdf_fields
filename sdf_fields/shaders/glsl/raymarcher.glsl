// shaders/glsl/raymarcher.glsl
// Complete ray marching framework with configurable parameters.
// Pair with primitives.glsl and operations.glsl.

#ifndef SDF_FIELDS_RAYMARCHER_GLSL
#define SDF_FIELDS_RAYMARCHER_GLSL

// --- Configuration (override before including) ---
#ifndef SDF_MAX_STEPS
#define SDF_MAX_STEPS 128
#endif

#ifndef SDF_MAX_DIST
#define SDF_MAX_DIST 100.0
#endif

#ifndef SDF_SURF_DIST
#define SDF_SURF_DIST 0.001
#endif

#ifndef SDF_STEP_MULT
#define SDF_STEP_MULT 1.0
#endif

// --- Ray marching core ---
// sceneSDF must be defined by the user: float sceneSDF(vec3 p)

// Returns: distance along ray to nearest surface, or -1.0 if no hit
float rayMarch(vec3 ro, vec3 rd) {
    float t = 0.0;
    for (int i = 0; i < SDF_MAX_STEPS; i++) {
        vec3 p = ro + rd * t;
        float d = sceneSDF(p);
        if (d < SDF_SURF_DIST) return t;
        t += d * SDF_STEP_MULT;
        if (t > SDF_MAX_DIST) break;
    }
    return -1.0;
}

// Ray march with step count output (for AO approximation or debugging)
float rayMarchCounted(vec3 ro, vec3 rd, out int steps) {
    float t = 0.0;
    steps = 0;
    for (int i = 0; i < SDF_MAX_STEPS; i++) {
        steps = i;
        vec3 p = ro + rd * t;
        float d = sceneSDF(p);
        if (d < SDF_SURF_DIST) return t;
        t += d * SDF_STEP_MULT;
        if (t > SDF_MAX_DIST) break;
    }
    return -1.0;
}

// --- Surface normal via central differences ---
vec3 calcNormal(vec3 p) {
    const float h = 0.0001;
    const vec2 k = vec2(1.0, -1.0);
    return normalize(
        k.xyy * sceneSDF(p + k.xyy * h) +
        k.yyx * sceneSDF(p + k.yyx * h) +
        k.yxy * sceneSDF(p + k.yxy * h) +
        k.xxx * sceneSDF(p + k.xxx * h)
    );
}

// --- Camera ray from UV ---
// ro = ray origin, ta = look-at target, uv = screen coordinates (-1 to 1)
vec3 cameraRay(vec3 ro, vec3 ta, vec2 uv, float fov) {
    vec3 fwd = normalize(ta - ro);
    vec3 right = normalize(cross(fwd, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, fwd);
    return normalize(fwd * fov + right * uv.x + up * uv.y);
}

// --- Soft shadow ---
// Returns 0.0 (full shadow) to 1.0 (no shadow)
float softShadow(vec3 ro, vec3 rd, float mint, float maxt, float k) {
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 64; i++) {
        float h = sceneSDF(ro + rd * t);
        res = min(res, k * h / t);
        t += clamp(h, 0.02, 0.2);
        if (h < 0.001 || t > maxt) break;
    }
    return clamp(res, 0.0, 1.0);
}

// --- Ambient Occlusion ---
float ambientOcclusion(vec3 p, vec3 n) {
    float occ = 0.0;
    float sca = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i);
        float d = sceneSDF(p + n * h);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}

#endif
