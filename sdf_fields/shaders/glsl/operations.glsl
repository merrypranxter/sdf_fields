// shaders/glsl/operations.glsl
// SDF boolean, smooth boolean, repetition, transform, and deformation operations.
// Based on Inigo Quilez's reference (iquilezles.org/articles/distfunctions).

#ifndef SDF_FIELDS_OPERATIONS_GLSL
#define SDF_FIELDS_OPERATIONS_GLSL

// ============================================================
//  BOOLEAN OPERATIONS (hard)
// ============================================================

float opUnion(float d1, float d2) { return min(d1, d2); }
float opIntersection(float d1, float d2) { return max(d1, d2); }
float opSubtraction(float d1, float d2) { return max(-d1, d2); }

// ============================================================
//  SMOOTH BOOLEAN OPERATIONS (polynomial smooth min/max)
// ============================================================

// Smooth union — k controls blend radius
float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Smooth subtraction — cuts d1 from d2 with soft edge
float opSmoothSubtraction(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d2, -d1, h) + k * h * (1.0 - h);
}

// Smooth intersection
float opSmoothIntersection(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

// ============================================================
//  REPETITION
// ============================================================

// Infinite repetition in all 3 axes
vec3 opRepeat(vec3 p, vec3 period) {
    return mod(p + 0.5 * period, period) - 0.5 * period;
}

// Limited repetition (finite grid of copies)
vec3 opRepeatLimited(vec3 p, vec3 period, vec3 limit) {
    return p - period * clamp(round(p / period), -limit, limit);
}

// Polar repetition around Y axis
vec3 opRepeatPolar(vec3 p, float count) {
    float angle = 6.2831853 / count;
    float a = atan(p.z, p.x);
    float r = length(p.xz);
    a = mod(a + 0.5 * angle, angle) - 0.5 * angle;
    return vec3(r * cos(a), p.y, r * sin(a));
}

// Mirror across X axis (bilateral symmetry)
vec3 opMirrorX(vec3 p) { p.x = abs(p.x); return p; }
vec3 opMirrorY(vec3 p) { p.y = abs(p.y); return p; }
vec3 opMirrorZ(vec3 p) { p.z = abs(p.z); return p; }

// ============================================================
//  SPATIAL TRANSFORMS
// ============================================================

vec3 opTranslate(vec3 p, vec3 offset) { return p - offset; }

mat2 _sdf_rot2(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }

vec3 opRotateX(vec3 p, float angle) { p.yz *= _sdf_rot2(angle); return p; }
vec3 opRotateY(vec3 p, float angle) { p.xz *= _sdf_rot2(angle); return p; }
vec3 opRotateZ(vec3 p, float angle) { p.xy *= _sdf_rot2(angle); return p; }

// Uniform scale — MUST multiply result by s
// Usage: sdSphere(p / s, r) * s
// (not a function because caller must handle the multiply)

// Elongation — stretch a shape along axes without distorting end caps
vec3 opElongate(vec3 p, vec3 h) {
    return p - clamp(p, -h, h);
}

// ============================================================
//  DEFORMATIONS (break exact distance — use smaller step sizes)
// ============================================================

// Twist around Y axis — twist_rate = radians per unit Y
vec3 opTwist(vec3 p, float twistRate) {
    float c = cos(twistRate * p.y);
    float s = sin(twistRate * p.y);
    mat2 m = mat2(c, -s, s, c);
    return vec3(m * p.xz, p.y);
}

// Bend along X axis
vec3 opBend(vec3 p, float bendAmount) {
    float c = cos(bendAmount * p.x);
    float s = sin(bendAmount * p.x);
    mat2 m = mat2(c, -s, s, c);
    vec2 bent = m * p.xy;
    return vec3(bent, p.z);
}

// Displacement — add noise or function to SDF value
// Usage: float d = sdSphere(p, 1.0) + opDisplace(p);
// (the displacement function is user-defined, this is a helper pattern)
float opDisplace(vec3 p, float amplitude, float frequency) {
    return amplitude * sin(frequency * p.x) * sin(frequency * p.y) * sin(frequency * p.z);
}

// Onion — hollow out a shape into a shell
float opOnion(float d, float thickness) {
    return abs(d) - thickness;
}

// Round — add rounding to any shape
float opRound(float d, float radius) {
    return d - radius;
}

// Extrude 2D SDF to 3D along Z
float opExtrude(float d2d, float pz, float h) {
    vec2 w = vec2(d2d, abs(pz) - h);
    return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

// Revolution — revolve 2D SDF around Y axis
float opRevolution(vec2 sdf2dInput, float py, float offset) {
    // sdf2dInput = vec2(length(p.xz) - offset, p.y) fed to 2D SDF
    // This is a helper — actual usage depends on the 2D primitive
    return length(sdf2dInput) - offset;
}

#endif
