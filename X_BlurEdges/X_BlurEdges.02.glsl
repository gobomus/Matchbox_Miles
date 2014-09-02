#version 120

uniform sampler2D Back;
uniform float adsk_result_w, adsk_result_h;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 back = texture2D(Back, st).rgb;

	gl_FragColor = vec4(back.rgb, 1.0);
}
	
	
