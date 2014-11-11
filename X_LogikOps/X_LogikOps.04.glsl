#version 120

#define in1 adsk_results_pass2
#define mt Matte2
#define ratio adsk_result_frameratio

uniform sampler2D in1, mt;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = texture2D(in1, st).rgb;
	float matte = texture2D(mt, st).r;

	gl_FragColor = vec4(col, matte);
}
