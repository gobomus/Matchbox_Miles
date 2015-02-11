#version 120

#define F adsk_results_pass3
#define B adsk_results_pass2
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D F, B;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec4 f = texture2D(F, st);
	vec4 b = texture2D(B, st);

	vec4 col = mix(b, f, f.a);

	gl_FragColor = col;
}
