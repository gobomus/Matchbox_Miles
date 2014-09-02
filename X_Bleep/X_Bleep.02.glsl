#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D Back;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 back = vec4(0.0);
	vec2 center = vec2(.5);

	back = texture2D(Back, st);

	gl_FragColor = back;
}
