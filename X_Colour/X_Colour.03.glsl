#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass2;
uniform vec2 swatch_pos;
uniform float swatch_size;
uniform float adsk_result_frameratio;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	float ratio = adsk_result_frameratio;

	vec2 ss = vec2(swatch_size/100.00);
	vec2 center = vec2(0.5);

	st = (st - swatch_pos) + center;
	st = (st-0.5)/ss+ vec2(0.5);

	vec4 swatch = texture2D(adsk_results_pass2, st);


	gl_FragColor = swatch;
}
