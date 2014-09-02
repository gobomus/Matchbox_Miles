#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float value;
uniform float adsk_result_frameratio;

const float pi = 3.14159265359;

vec4 rgb2hsv(vec4 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, c.a);
}

vec4 hsv2rgb(vec4 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec4 p = vec4(abs(fract(c.xxx + K.xyz) * 6.0 - K.www), c.a);

    return c.z * mix(K.xxxx, clamp(p - K.xxxx, 0.0, 1.0), c.y);
}

vec4 getrgb(vec4 hsv) {
	float h = hsv.r;
    float s = hsv.g;
    float v = hsv.b;

	int i = int(floor(h));
	float fi = float(i);

	float f = 1.0 - (h - fi);

	if (bool(mod(fi, 2.0))) {
		f = h - fi;
	}

	float m = 0.0;
	float n = 1.0 - f;

	vec3 result = vec3(0.0);

	if (i == 0) {
		result = vec3(v, n, m);
	} else if (i == 1) {
		result = vec3(n, v, m);
	} else if (i == 2) {
		result = vec3(m, v, n);
	} else if (i == 3) {
		result = vec3(m, n, v);
	} else if (i == 4) {
		result = vec3(n, m, v);
	} else if (i == 5) {
		result = vec3(v, m, n);
	} else {
		result = vec3(v, n, m);
	}

	if (h == -1.0) {
		return vec4(v, v, v, hsv.a);
	} else {
		return vec4(result, hsv.a);
	}
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	float ratio = adsk_result_frameratio;

	float radius = .5;
	vec2 center = vec2(.5);

	st.x *= ratio;
    vec2 v0 = st;
	st.x /= ratio;

	center.x *= ratio;
	float dist = length(v0 - center);
	center.x /= ratio;
	v0.x /= ratio;

    vec2 v1 = vec2(v0.x, radius);
    float a = distance(v0, v1);
    float b = distance(v1, center);
    
    float angle = atan(a,b);


	if (v0.x > radius) {
		if (v0.y > radius) {
			angle = atan(b,a) + pi/2.0;
		} else {
			angle = atan(a,b) + pi;
		}
	} else {
		if (v0.y < radius) {
			angle = atan(b,a) + (pi * 1.5);
		} else {
			angle = atan(a,b);
		}
	}
    
    vec4 theColor = vec4(1.0);
    

	angle *= 3.0 / pi;
    theColor.r = angle;

    theColor.a = clamp(radius - dist, 0.0, 1.0);
	float alpha = theColor.a;
	alpha = smoothstep(0.0, .01, alpha);
	alpha = 1.0 - alpha;

	theColor = getrgb(theColor);
	theColor = rgb2hsv(theColor);

    st.x *= ratio;
	center.x *= ratio;
	theColor.g = clamp(distance(center, st) * 2.0, 0.0, 1.0);
	center.x /= ratio;
    st.x /= ratio;

	theColor.b = value;

	theColor = hsv2rgb(theColor);

	theColor = clamp(theColor, 0.0, 1.0);

	theColor.a = alpha;

	gl_FragColor = theColor;
}
