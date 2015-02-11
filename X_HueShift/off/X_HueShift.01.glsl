#version 120

uniform sampler2D Front;
uniform float adsk_result_w, adsk_result_h;

vec2 res = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = texture2D(Front, st).rgb;

	gl_FragColor.rgb = col;
}
