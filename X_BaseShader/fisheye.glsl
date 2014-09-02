#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define white vec4(1.0)
#define black vec4(0.0)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

#define DEV

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform float radius;
uniform float scale;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	st = (st - .5) * 2.0;


	float lon = st.x * 3.14;
	float lat = atan(exp(-2 * 3.14 *st.y));

	float z = 1.0 + lat * cos(lon / 2.0);
	float x = cos(lat) * sin(lon / 2.0) / sqrt(z);
	float y = sin(lat) / sqrt(z);

	st = vec2(x,y);


	vec3 col = tex(INPUT, st);

	gl_FragColor = vec4(col, 0.0);
}
