#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3;

uniform vec3 color;
uniform float rot;
uniform float gamma;
uniform float contrast;
uniform float saturation;
uniform int result;
uniform float gain;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

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
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec3 front = texture2D(adsk_results_pass1, st).rgb;
	vec3 back = texture2D(adsk_results_pass2, st).rgb;
	float matte = texture2D(adsk_results_pass3, st).a;

	vec3 lc = vec3(0.2125, 0.7154, 0.0721);
	vec3 luma = clamp(vec3(dot(front, lc)), 0.0, 1.0);
	vec3 gray = vec3(.5);

	vec3 midtones = color;
	vec3 hsv = rgb2hsv(midtones);

	vec3 shad = hsv;
	shad.r = hsv.r - fract(rot / 360.0);

	vec3 high = hsv;
	high.r = hsv.r + fract(rot / 360.0);

	vec3 comp = mix(hsv2rgb(shad), midtones, luma);
	comp = mix(comp, hsv2rgb(high), pow(luma.r, gamma + 1.0));
	comp = mix(luma, comp, saturation / 100.0);
	comp = clamp(comp, 0.0, 1.0);

	
	luma = mix(gray, luma, contrast);
	luma *= gain;

	if (result == 0) {
		comp = mix(vec3(0.0), comp, luma);
	} else if (result == 1) {
		comp = mix(back, comp, luma);
	} else if (result == 2) {
		comp = mix(back, comp, luma * matte);
	}


	gl_FragColor = vec4(comp, luma.r);
}
