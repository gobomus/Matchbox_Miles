#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

//uniform sampler2D Front;

uniform bool repeat_texture;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = vec4(0.0);
	vec2 center = vec2(.5);

	gl_FragColor = vec4(st.r, st.g, 0.0, 0.0);
}
