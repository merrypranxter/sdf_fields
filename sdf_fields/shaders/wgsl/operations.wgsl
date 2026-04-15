// shaders/wgsl/operations.wgsl
// SDF operations — WGSL port.

// Boolean
fn opUnion(d1: f32, d2: f32) -> f32 { return min(d1, d2); }
fn opIntersection(d1: f32, d2: f32) -> f32 { return max(d1, d2); }
fn opSubtraction(d1: f32, d2: f32) -> f32 { return max(-d1, d2); }

// Smooth Boolean
fn opSmoothUnion(d1: f32, d2: f32, k: f32) -> f32 {
    let h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}
fn opSmoothSubtraction(d1: f32, d2: f32, k: f32) -> f32 {
    let h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d2, -d1, h) + k * h * (1.0 - h);
}
fn opSmoothIntersection(d1: f32, d2: f32, k: f32) -> f32 {
    let h = clamp(0.5 - 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) + k * h * (1.0 - h);
}

// Repetition
fn opRepeat(p: vec3<f32>, period: vec3<f32>) -> vec3<f32> {
    return ((p + 0.5 * period) % period) - 0.5 * period;
}
fn opRepeatLimited(p: vec3<f32>, period: vec3<f32>, limit: vec3<f32>) -> vec3<f32> {
    return p - period * clamp(round(p / period), -limit, limit);
}
fn opRepeatPolar(p: vec3<f32>, count: f32) -> vec3<f32> {
    let angle = 6.2831853 / count;
    var a = atan2(p.z, p.x);
    let r = length(p.xz);
    a = ((a + 0.5 * angle) % angle) - 0.5 * angle;
    return vec3<f32>(r * cos(a), p.y, r * sin(a));
}
fn opMirrorX(p: vec3<f32>) -> vec3<f32> { return vec3<f32>(abs(p.x), p.y, p.z); }

// Transforms
fn opTranslate(p: vec3<f32>, offset: vec3<f32>) -> vec3<f32> { return p - offset; }

fn opTwist(p: vec3<f32>, twistRate: f32) -> vec3<f32> {
    let c = cos(twistRate * p.y); let s = sin(twistRate * p.y);
    return vec3<f32>(c * p.x - s * p.z, p.y, s * p.x + c * p.z);
}
fn opBend(p: vec3<f32>, bendAmount: f32) -> vec3<f32> {
    let c = cos(bendAmount * p.x); let s = sin(bendAmount * p.x);
    return vec3<f32>(c * p.x - s * p.y, s * p.x + c * p.y, p.z);
}
fn opOnion(d: f32, thickness: f32) -> f32 { return abs(d) - thickness; }
fn opRound(d: f32, radius: f32) -> f32 { return d - radius; }
fn opElongate(p: vec3<f32>, h: vec3<f32>) -> vec3<f32> { return p - clamp(p, -h, h); }
