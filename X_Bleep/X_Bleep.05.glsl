#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3, adsk_results_pass4;
uniform float lod;
uniform int result;

#extension GL_ARB_shader_texture_lod : enable


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	float strength = texture2D(adsk_results_pass3, st).r;

	vec4 comp = vec4(0.0);


	vec4 bleeped = texture2DLod(adsk_results_pass4, st, lod * strength);

	if (result == 0) {
		vec4 front = texture2D(adsk_results_pass1, st);
		comp = bleeped + front * (1.0 - bleeped.a);
	} else if (result == 1) {
		vec4 back = texture2D(adsk_results_pass2, st);
		comp = bleeped + back * (1.0 - bleeped.a);
	} else if (result == 2) {
		comp = bleeped;
	}


	gl_FragColor = vec4(comp.rgb, bleeped.a);
}
