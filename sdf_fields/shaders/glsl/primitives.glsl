// shaders/glsl/primitives.glsl
// SDF primitive functions — all return signed distance from point p to surface.
// Based on Inigo Quilez's SDF reference (iquilezles.org/articles/distfunctions).

#ifndef SDF_FIELDS_PRIMITIVES_GLSL
#define SDF_FIELDS_PRIMITIVES_GLSL

// --- Sphere ---
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

// --- Box (exact) ---
float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

// --- Rounded Box ---
float sdRoundBox(vec3 p, vec3 b, float r) {
    return sdBox(p, b) - r;
}

// --- Torus ---
// t.x = major radius, t.y = tube radius
float sdTorus(vec3 p, vec2 t) {
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

// --- Capped Cylinder (vertical, centered at origin) ---
float sdCylinder(vec3 p, float r, float h) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// --- Infinite Cylinder (along Y) ---
float sdCylinderInfinite(vec3 p, float r) {
    return length(p.xz) - r;
}

// --- Capsule / Line Segment ---
float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// --- Vertical Capsule (centered at origin, total height h) ---
float sdCapsuleVertical(vec3 p, float h, float r) {
    p.y -= clamp(p.y, 0.0, h);
    return length(p) - r;
}

// --- Infinite Plane ---
// n.xyz = normal (must be normalized), n.w = offset
float sdPlane(vec3 p, vec4 n) {
    return dot(p, n.xyz) + n.w;
}

// --- Octahedron (exact) ---
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = p.x + p.y + p.z - s;
    vec3 q;
    if (3.0 * p.x < m) q = p.xyz;
    else if (3.0 * p.y < m) q = p.yzx;
    else if (3.0 * p.z < m) q = p.zxy;
    else return m * 0.57735027;
    float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
    return length(vec3(q.x, q.y - s + k, q.z - k));
}

// --- Gyroid (approximate SDF) ---
// Returns abs(implicit) - thickness; use step multiplier ~0.7
float sdGyroid(vec3 p, float scale, float thickness, float threshold) {
    p *= scale;
    float g = sin(p.x) * cos(p.y) + sin(p.y) * cos(p.z) + sin(p.z) * cos(p.x) - threshold;
    return (abs(g) - thickness) / scale;
}

// --- Mandelbulb Fractal (approximate SDF via distance estimator) ---
// EXPENSIVE: ~8-15 iterations per eval. Use step multiplier 0.5.
float sdMandelbulb(vec3 p, float power, int iterations, float bailout) {
    vec3 z = p;
    float dr = 1.0;
    float r = 0.0;
    for (int i = 0; i < iterations; i++) {
        r = length(z);
        if (r > bailout) break;
        // Convert to spherical
        float theta = acos(z.z / r);
        float phi = atan(z.y, z.x);
        dr = pow(r, power - 1.0) * power * dr + 1.0;
        // Scale and rotate
        float zr = pow(r, power);
        theta *= power;
        phi *= power;
        // Convert back to cartesian
        z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
        z += p;
    }
    return 0.5 * log(r) * r / dr;
}

// === 2D SDF Primitives ===

float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

float sdBox2D(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdSegment2D(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

#endif
