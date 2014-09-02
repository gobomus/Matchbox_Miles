#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Front;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 1.0);
}
