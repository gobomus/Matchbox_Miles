#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Back;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 back = texture2D(Back, st).rgb;

	gl_FragColor = vec4(back, 1.0);
}
