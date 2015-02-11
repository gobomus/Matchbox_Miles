#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio, adsk_time;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

const float pi = 3.141592653589793238462643383279502884197969;

uniform float freq;
uniform float amp;
uniform float m;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	float o = 2 * pi * st.x * freq;
	float h = amp * sin(o + adsk_time);

	h = h * .5 + .5;

	float s = step(h, st.y);
	float d = fwidth(s);

	float f = clamp((st.y + d / 2.0 - h) / d, 0.0, 1.0);

	vec4 col = vec4(s);

	gl_FragColor = col;
}
