#version 120

uniform sampler2D Front, Matte;
uniform float adsk_result_w, adsk_result_h;

vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float r, g, b, c, m, y;
uniform float rs, gs, bs, cs, ms, ys;
uniform float f;

// hsv conversion from here: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
	/*
	yellow .1663
	cyan .5
	green .33325
	magenta .83301
	red 0.0
	blue .66650
	*/

	float rv = 0.0;
	float yv = .16663;
	float gv = .33325;
	float cv = .5;
	float bv = .66650;
	float mv = .83301;

	vec2 st = gl_FragCoord.xy / res;

	vec3 col = texture2D(Front, st).rgb;
	float mt = texture2D(Matte, st).r;

	vec3 hsv = rgb2hsv(col);

	float h = hsv.r;
	float s = hsv.g;
	float v = hsv.b;

	float ydiff = 1.0 - abs(h - yv);
	float yh = mix(1.0, h, y + 1.0);

	float gdiff = 1.0 - abs(h - gv);
	float gh = mix(1.0, h, g + 1.0);

	float cdiff = 1.0 - abs(h - cv);
	float ch = mix(1.0, h, c + 1.0);

	float bdiff = 1.0 - abs(h - bv);
	float bh = mix(1.0, h, b + 1.0);

	float mdiff = 1.0 - abs(h - mv);
	float mh = mix(1.0, h, m + 1.0);

	float rdiff = 1.0 - abs(h - rv);
	float rh = mix(1.0, h, r + 1.0);

	if (ydiff > f) {
		h = mix(h, yh, ydiff);
		s = mix(s, s * ys, ydiff);
	}

	if (gdiff > f) {
		h = mix(h, gh, gdiff);
		s = mix(s, s * gs, gdiff);
	}
	
	if (cdiff > f) {
		h = mix(h, ch, cdiff);
		s = mix(s, s * cs, cdiff);
	}
	
	if (bdiff > f) {
		h = mix(h, bh, bdiff);
		s = mix(s, s * bs, bdiff);
	}

	if (mdiff > f) {
		h = mix(h, mh, mdiff);
		s = mix(s, s * ms, mdiff);
	}
	
	if (rdiff > f) {
		h = mix(h, rh, rdiff);
		s = mix(s, s * rs, rdiff);
	}

	hsv.r = h;
	hsv.g = s;

	col = mix(col, hsv2rgb(hsv), mt);

	gl_FragColor.rgb = col;
}
