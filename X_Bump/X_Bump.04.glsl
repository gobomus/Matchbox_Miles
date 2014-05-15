#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D adsk_results_pass1, adsk_results_pass3;

uniform bool repeat_texture;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = vec3(0.0);

	gl_FragColor = vec4(premult, matte);
}
