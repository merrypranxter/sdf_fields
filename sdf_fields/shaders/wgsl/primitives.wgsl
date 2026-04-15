// shaders/wgsl/primitives.wgsl
// SDF primitive functions — WGSL port.

fn sdSphere(p: vec3<f32>, r: f32) -> f32 { return length(p) - r; }

fn sdBox(p: vec3<f32>, b: vec3<f32>) -> f32 {
    let q = abs(p) - b;
    return length(max(q, vec3<f32>(0.0))) + min(max(q.x, max(q.y, q.z)), 0.0);
}

fn sdRoundBox(p: vec3<f32>, b: vec3<f32>, r: f32) -> f32 { return sdBox(p, b) - r; }

fn sdTorus(p: vec3<f32>, t: vec2<f32>) -> f32 {
    let q = vec2<f32>(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

fn sdCylinder(p: vec3<f32>, r: f32, h: f32) -> f32 {
    let d = abs(vec2<f32>(length(p.xz), p.y)) - vec2<f32>(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, vec2<f32>(0.0)));
}

fn sdCapsule(p: vec3<f32>, a: vec3<f32>, b: vec3<f32>, r: f32) -> f32 {
    let pa = p - a; let ba = b - a;
    let h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

fn sdPlane(p: vec3<f32>, n: vec3<f32>, h: f32) -> f32 { return dot(p, normalize(n)) + h; }

fn sdOctahedron(p_in: vec3<f32>, s: f32) -> f32 {
    let p = abs(p_in);
    let m = p.x + p.y + p.z - s;
    var q: vec3<f32>;
    if (3.0 * p.x < m) { q = p; }
    else if (3.0 * p.y < m) { q = vec3<f32>(p.y, p.z, p.x); }
    else if (3.0 * p.z < m) { q = vec3<f32>(p.z, p.x, p.y); }
    else { return m * 0.57735027; }
    let k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
    return length(vec3<f32>(q.x, q.y - s + k, q.z - k));
}

fn sdGyroid(p: vec3<f32>, scale: f32, thickness: f32, threshold: f32) -> f32 {
    let sp = p * scale;
    let g = sin(sp.x) * cos(sp.y) + sin(sp.y) * cos(sp.z) + sin(sp.z) * cos(sp.x) - threshold;
    return (abs(g) - thickness) / scale;
}

fn sdMandelbulb(p: vec3<f32>, power: f32, iterations: i32, bailout: f32) -> f32 {
    var z = p;
    var dr = 1.0;
    var r = 0.0;
    for (var i = 0; i < iterations; i++) {
        r = length(z);
        if (r > bailout) { break; }
        let theta = acos(z.z / r);
        let phi = atan2(z.y, z.x);
        dr = pow(r, power - 1.0) * power * dr + 1.0;
        let zr = pow(r, power);
        let t2 = theta * power;
        let p2 = phi * power;
        z = zr * vec3<f32>(sin(t2) * cos(p2), sin(p2) * sin(t2), cos(t2)) + p;
    }
    return 0.5 * log(r) * r / dr;
}

fn sdCircle(p: vec2<f32>, r: f32) -> f32 { return length(p) - r; }
fn sdBox2D(p: vec2<f32>, b: vec2<f32>) -> f32 {
    let d = abs(p) - b;
    return length(max(d, vec2<f32>(0.0))) + min(max(d.x, d.y), 0.0);
}
