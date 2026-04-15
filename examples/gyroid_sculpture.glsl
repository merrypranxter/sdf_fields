// examples/gyroid_sculpture.glsl
// ShaderToy: Gyroid minimal surface bounded by a sphere. Studio lighting + AO.
// Paste into shadertoy.com as Image shader.

float sdSphere(vec3 p, float r) { return length(p) - r; }

float sdGyroid(vec3 p, float s, float th) {
    p *= s;
    float g = sin(p.x)*cos(p.y) + sin(p.y)*cos(p.z) + sin(p.z)*cos(p.x);
    return (abs(g) - th) / s;
}

float sceneSDF(vec3 p) {
    // Slowly rotate the whole thing
    float a = iTime * 0.2;
    float c = cos(a), s = sin(a);
    p.xz = mat2(c,-s,s,c) * p.xz;

    float gyroid = sdGyroid(p, 3.14159, 0.25);
    float bound = sdSphere(p, 2.2);
    return max(gyroid, bound); // Intersection: bound the gyroid
}

vec3 calcNormal(vec3 p) {
    vec2 e = vec2(0.0005, 0.0);
    return normalize(vec3(
        sceneSDF(p+e.xyy)-sceneSDF(p-e.xyy),
        sceneSDF(p+e.yxy)-sceneSDF(p-e.yxy),
        sceneSDF(p+e.yyx)-sceneSDF(p-e.yyx)));
}

float ao(vec3 p, vec3 n) {
    float occ = 0.0, w = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12*float(i);
        occ += (h - sceneSDF(p + n*h)) * w;
        w *= 0.95;
    }
    return clamp(1.0 - 3.0*occ, 0.0, 1.0);
}

void mainImage(out vec4 O, vec2 F) {
    vec2 uv = (2.0*F - iResolution.xy) / iResolution.y;
    vec3 ro = vec3(0, 0.5, -5);
    vec3 ta = vec3(0, 0, 0);
    vec3 fwd = normalize(ta-ro);
    vec3 right = normalize(cross(fwd, vec3(0,1,0)));
    vec3 up = cross(right, fwd);
    vec3 rd = normalize(fwd*2.0 + right*uv.x + up*uv.y);

    float t = 0.0;
    for (int i = 0; i < 150; i++) {
        float d = sceneSDF(ro + rd*t);
        if (d < 0.0005) break;
        t += d * 0.7; // Step multiplier for gyroid
        if (t > 50.0) break;
    }

    vec3 col = vec3(0.08, 0.08, 0.12); // Dark background
    if (t < 50.0) {
        vec3 p = ro + rd*t;
        vec3 n = calcNormal(p);
        float occ = ao(p, n);

        // Three-point lighting
        vec3 l1 = normalize(vec3(2, 3, -1));
        vec3 l2 = normalize(vec3(-2, 1, 1));
        float d1 = max(dot(n, l1), 0.0);
        float d2 = max(dot(n, l2), 0.0);

        col = vec3(0.85, 0.75, 0.65) * d1 * 0.6;
        col += vec3(0.3, 0.4, 0.6) * d2 * 0.3;
        col += vec3(0.12, 0.1, 0.08); // Ambient
        col *= occ;

        // Fresnel rim
        float fres = pow(1.0 - max(dot(n, -rd), 0.0), 4.0);
        col += vec3(0.4, 0.5, 0.7) * fres * 0.4;
    }

    // Fog
    col = mix(col, vec3(0.08, 0.08, 0.12), 1.0 - exp(-t*0.06));

    O = vec4(pow(col, vec3(0.4545)), 1.0);
}
