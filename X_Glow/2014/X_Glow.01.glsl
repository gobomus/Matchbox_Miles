#version 120

#define INPUT Front
#define MAT Matte
#define tex(col, coords) texture2D(col, coords).rgb

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);

	gl_FragColor = vec4(col, 0.0);
}
