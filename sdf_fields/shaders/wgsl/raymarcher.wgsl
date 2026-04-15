// shaders/wgsl/raymarcher.wgsl
// Ray marching framework — WGSL port.
// User must define: fn sceneSDF(p: vec3<f32>) -> f32

const SDF_MAX_STEPS: i32 = 128;
const SDF_MAX_DIST: f32 = 100.0;
const SDF_SURF_DIST: f32 = 0.001;

fn rayMarch(ro: vec3<f32>, rd: vec3<f32>) -> f32 {
    var t = 0.0;
    for (var i = 0; i < SDF_MAX_STEPS; i++) {
        let p = ro + rd * t;
        let d = sceneSDF(p);
        if (d < SDF_SURF_DIST) { return t; }
        t += d;
        if (t > SDF_MAX_DIST) { break; }
    }
    return -1.0;
}

fn calcNormal(p: vec3<f32>) -> vec3<f32> {
    let h = 0.0001;
    return normalize(vec3<f32>(
        sceneSDF(p + vec3<f32>(h, -h, -h)) - sceneSDF(p + vec3<f32>(-h, h, h)),
        sceneSDF(p + vec3<f32>(-h, h, -h)) - sceneSDF(p + vec3<f32>(h, -h, h)),
        sceneSDF(p + vec3<f32>(-h, -h, h)) - sceneSDF(p + vec3<f32>(h, h, -h))
    ));
}

fn cameraRay(ro: vec3<f32>, ta: vec3<f32>, uv: vec2<f32>, fov: f32) -> vec3<f32> {
    let fwd = normalize(ta - ro);
    let right = normalize(cross(fwd, vec3<f32>(0.0, 1.0, 0.0)));
    let up = cross(right, fwd);
    return normalize(fwd * fov + right * uv.x + up * uv.y);
}

fn softShadow(ro: vec3<f32>, rd: vec3<f32>, mint: f32, maxt: f32, k: f32) -> f32 {
    var res = 1.0;
    var t = mint;
    for (var i = 0; i < 64; i++) {
        let h = sceneSDF(ro + rd * t);
        res = min(res, k * h / t);
        t += clamp(h, 0.02, 0.2);
        if (h < 0.001 || t > maxt) { break; }
    }
    return clamp(res, 0.0, 1.0);
}

fn ambientOcclusion(p: vec3<f32>, n: vec3<f32>) -> f32 {
    var occ = 0.0;
    var sca = 1.0;
    for (var i = 0; i < 5; i++) {
        let h = 0.01 + 0.12 * f32(i);
        let d = sceneSDF(p + n * h);
        occ += (h - d) * sca;
        sca *= 0.95;
    }
    return clamp(1.0 - 3.0 * occ, 0.0, 1.0);
}
