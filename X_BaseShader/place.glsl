#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform float width;
uniform vec2 center;
uniform vec2 move;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = vec3(0.0);

			st -= move;
	if (distance(st.x, center.x) < width * .5) {
		if (distance(st.y, center.y) < width * .5) {
			col = texture2D(INPUT, st).rgb;
		}
	}


	gl_FragColor = vec4(col, 0.0);
}
