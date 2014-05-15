#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D Original, Denoise, Comp;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 original = texture2D(Original, st);
	vec4 denoised = texture2D(Denoise, st);
	vec4 comp = texture2D(Comp, st);

	vec4 difference = original - denoised;

	gl_FragColor = comp + difference;
}
