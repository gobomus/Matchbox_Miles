#version 120

#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D adsk_results_pass2, adsk_results_pass4;
uniform float adsk_result_w, adsk_result_h;

vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float r, g, b, c, m, y;
uniform float rs, gs, bs, cs, ms, ys;
uniform float f;

// hsv conversion from here: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    //return c.z * mix(K.xxx, p - K.xxx, c.y);
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

	float yv = .16663;
	float gv = .33325;
	float cv = .5;
	float mv = .83301;
	float rv = 0.0;
	float bv = .66650;

	vec2 texel = 1.0 / res;

	vec2 st = gl_FragCoord.xy / res;
	vec3 hsv = texture2D(adsk_results_pass4, st).rgb;
	vec3 hsv2 = texture2D(adsk_results_pass2, st).rgb;

	hsv = clamp(hsv, 0.0, 1.0);

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
	hsv.b = hsv2.b;

	vec3 col = hsv2rgb(hsv);

	gl_FragColor.rgb = col;
}
