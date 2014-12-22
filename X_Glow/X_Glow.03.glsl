#version 120

#define INPUT adsk_results_pass1
#define MAT Matte

uniform sampler2D INPUT, MAT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = texture2D(INPUT, st).rgb;
	float mat = texture2D(MAT, st).r;

	mat = clamp(mat, 0.0, 1.0);

	gl_FragColor = vec4(col, mat);
}
