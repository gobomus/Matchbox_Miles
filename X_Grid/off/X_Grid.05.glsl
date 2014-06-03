#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass3;

uniform float lod;

#extension GL_ARB_shader_texture_lod : enable

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec4 grid = texture2DLod(adsk_results_pass1, st, lod);

	gl_FragColor = grid;
}
