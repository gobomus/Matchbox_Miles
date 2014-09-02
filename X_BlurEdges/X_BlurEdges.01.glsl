#version 120

uniform sampler2D Front;
uniform float adsk_result_w, adsk_result_h;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front.rgb, 1.0);
}
	
	
