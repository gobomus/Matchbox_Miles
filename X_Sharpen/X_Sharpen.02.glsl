#version 120

#define INPUT Strength
#define mat(col, coords) texture2D(col, coords).r

uniform sampler2D INPUT, MAT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	float mt = mat(INPUT, st);

	gl_FragColor = vec4(mt);
}
