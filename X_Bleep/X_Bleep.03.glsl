#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D Matte;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 matte = texture2D(Matte, st);

	gl_FragColor = vec4(matte.rgb, matte.r);
}
