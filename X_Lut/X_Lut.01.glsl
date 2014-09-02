#version 120

#define INPUT Front
#define LUT Lut
#define tex(col, coords) texture2D(col, coords).rgb
#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform float adsk_time;
uniform sampler2D INPUT, LUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec2 i;
uniform vec2 k;


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 lut = tex(LUT, st);

	vec3 col = tex(INPUT, st);
	

	col = reflect(col, normalize(lut));

	gl_FragColor = vec4(col, 0.0);
}
