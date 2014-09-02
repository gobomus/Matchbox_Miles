#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform sampler2D adsk_results_pass1;
uniform int lod;

#extension GL_ARB_shader_texture_lod : enable


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 image = texture2DLod(adsk_results_pass1, st, float(lod));

	gl_FragColor = image;

}
