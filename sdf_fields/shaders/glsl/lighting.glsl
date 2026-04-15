// shaders/glsl/lighting.glsl
// Lighting utilities for SDF ray marched scenes.

#ifndef SDF_FIELDS_LIGHTING_GLSL
#define SDF_FIELDS_LIGHTING_GLSL

// --- Basic diffuse + specular (Blinn-Phong) ---
vec3 lightingBasic(vec3 p, vec3 n, vec3 rd, vec3 lightDir, vec3 albedo, float shininess) {
    float diff = max(dot(n, lightDir), 0.0);
    vec3 halfDir = normalize(lightDir - rd);
    float spec = pow(max(dot(n, halfDir), 0.0), shininess);
    vec3 ambient = 0.1 * albedo;
    return ambient + albedo * diff + vec3(1.0) * spec * 0.5;
}

// --- Fresnel approximation (Schlick) ---
float fresnel(vec3 normal, vec3 viewDir, float F0) {
    float cosTheta = clamp(dot(normal, -viewDir), 0.0, 1.0);
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// --- Matcap-style hemispheric lighting ---
vec3 lightingHemisphere(vec3 n, vec3 skyColor, vec3 groundColor) {
    float t = 0.5 + 0.5 * n.y;
    return mix(groundColor, skyColor, t);
}

// --- Normal-based color (debug / artistic) ---
vec3 normalColor(vec3 n) {
    return n * 0.5 + 0.5;
}

// --- Fog (exponential) ---
vec3 applyFog(vec3 color, float dist, vec3 fogColor, float density) {
    float fog = 1.0 - exp(-dist * density);
    return mix(color, fogColor, fog);
}

// --- Glow / volumetric accumulation ---
// Call inside the ray march loop: glow += glowContribution(d, glowRadius)
float glowContribution(float d, float radius) {
    return radius / (d * d + radius * radius);
}

// --- Step-count based coloring (for debugging / art) ---
vec3 stepCountColor(int steps, int maxSteps) {
    float t = float(steps) / float(maxSteps);
    // Cool to warm gradient: blue (few steps) → red (many steps)
    return vec3(t, 0.2, 1.0 - t);
}

#endif
