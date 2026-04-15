// shaders/wgsl/lighting.wgsl
// Lighting utilities — WGSL port.

fn lightingBasic(p: vec3<f32>, n: vec3<f32>, rd: vec3<f32>, lightDir: vec3<f32>, albedo: vec3<f32>, shininess: f32) -> vec3<f32> {
    let diff = max(dot(n, lightDir), 0.0);
    let halfDir = normalize(lightDir - rd);
    let spec = pow(max(dot(n, halfDir), 0.0), shininess);
    let ambient = 0.1 * albedo;
    return ambient + albedo * diff + vec3<f32>(1.0) * spec * 0.5;
}

fn fresnel(normal: vec3<f32>, viewDir: vec3<f32>, F0: f32) -> f32 {
    let cosTheta = clamp(dot(normal, -viewDir), 0.0, 1.0);
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

fn lightingHemisphere(n: vec3<f32>, skyColor: vec3<f32>, groundColor: vec3<f32>) -> vec3<f32> {
    let t = 0.5 + 0.5 * n.y;
    return mix(groundColor, skyColor, t);
}

fn normalColor(n: vec3<f32>) -> vec3<f32> { return n * 0.5 + vec3<f32>(0.5); }

fn applyFog(color: vec3<f32>, dist: f32, fogColor: vec3<f32>, density: f32) -> vec3<f32> {
    let fog = 1.0 - exp(-dist * density);
    return mix(color, fogColor, fog);
}

fn glowContribution(d: f32, radius: f32) -> f32 {
    return radius / (d * d + radius * radius);
}
