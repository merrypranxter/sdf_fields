// examples/smooth_blobs.glsl
// ShaderToy: Animated smooth-union metaballs. Demonstrates melting_blobs recipe.
// Paste into shadertoy.com as Image shader.

float sdSphere(vec3 p, float r) { return length(p) - r; }

float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k*h*(1.0-h);
}

float sceneSDF(vec3 p) {
    float t = iTime * 0.8;
    float d = sdSphere(p - vec3(sin(t)*1.5, cos(t*0.7)*0.5, 0.0), 0.8);
    d = opSmoothUnion(d, sdSphere(p - vec3(-sin(t*0.6)*1.2, sin(t)*0.8, cos(t*0.4)), 0.7), 0.8);
    d = opSmoothUnion(d, sdSphere(p - vec3(cos(t*0.9)*0.8, -sin(t*0.5)*1.0, sin(t*0.3)*0.6), 0.6), 0.8);
    d = opSmoothUnion(d, sdSphere(p - vec3(0.0, sin(t*1.1)*0.4, cos(t*0.8)*1.3), 0.9), 0.8);
    return d;
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        sceneSDF(p+e.xyy)-sceneSDF(p-e.xyy),
        sceneSDF(p+e.yxy)-sceneSDF(p-e.yxy),
        sceneSDF(p+e.yyx)-sceneSDF(p-e.yyx)));
}

void mainImage(out vec4 O, vec2 F) {
    vec2 uv = (2.0*F - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0, -5);
    vec3 rd = normalize(vec3(uv, 1.8));

    float t = 0.0;
    for (int i = 0; i < 100; i++) {
        float d = sceneSDF(ro + rd*t);
        if (d < 0.001) break;
        t += d;
        if (t > 50.0) break;
    }

    vec3 col = vec3(0.02, 0.02, 0.05);
    if (t < 50.0) {
        vec3 p = ro + rd*t;
        vec3 n = calcNormal(p);
        vec3 light = normalize(vec3(1, 2, -1));
        float diff = max(dot(n, light), 0.0);
        float fres = pow(1.0 - max(dot(n, -rd), 0.0), 3.0);
        col = mix(vec3(0.2, 0.5, 0.8), vec3(1.0, 0.3, 0.5), fres) * (0.15 + diff * 0.85);
        col += vec3(1.0, 0.9, 0.8) * pow(max(dot(reflect(-light, n), -rd), 0.0), 32.0) * 0.5;
    }
    O = vec4(pow(col, vec3(0.4545)), 1.0);
}
