#version 120

#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D Front;
uniform float adsk_result_w, adsk_result_h;

vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float sat;
uniform float clip;



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
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = texture2D(Front, st).rgb;

	float bw = luma(col);

	vec3 hsv = rgb2hsv(col);

	float mt = mix(1.0, hsv.b, clip);

	if (hsv.g > .875) {
		hsv.g = mix(hsv.g, .875, mt);
	}

	col = hsv2rgb(hsv);

	gl_FragColor = vec4(col, mt);
}
