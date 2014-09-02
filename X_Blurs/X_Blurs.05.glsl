#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Strength;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 strength = texture2D(Strength, st);

	gl_FragColor = vec4(strength.rgb, strength.r);
}
