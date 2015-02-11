#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT, Back, Keyin;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;


uniform bool RGB;
uniform bool YUV;
uniform bool YIQ;
uniform vec3 blend;
uniform float contrast;

#define diff(base, blend)   abs(base - blend)

vec3 yuv(vec3 col)
{
	mat3 m = mat3(
		.2126, .7152, .0722,
		-.09991, -.33609, .436,
		.615, -.55861, -.05639
	);

	return col * m;
}

vec3 rgb(vec3 col)
{
	return col;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(INPUT, st).rgb;
	vec3 back = texture2D(Back, st).rgb;
	vec3 key = texture2D(Keyin, st).rgb;

	vec3 outc = front;

	//key = mix(key, front, blendb);
	vec3 matte_rgb = diff(key, front);

	front = yuv(front);
	key = yuv(key);

	vec3 matte_yuv = diff(key, front);

	vec3 col_max = max(matte_rgb, matte_yuv);
	col_max = mix(vec3(0.0), col_max, blend);

	float matte = max(max(col_max.r, col_max.g), col_max.b);
	matte = mix(.5, matte, contrast);
	matte = clamp(matte, 0.0, 1.0);

	outc = mix(back, outc, matte);

	gl_FragColor = vec4(outc, matte);
}
