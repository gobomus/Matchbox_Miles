jversion 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)

#define luma(col) sqrt(dot(col * col, vec3(0.299, 0.587, 0.114)))
#define tex(col, coords) texture2D(col, coords).rgb
#define oc gl_FragColor.rgb

uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D INPUT;

const vec2 texel = vec2(1.0) / res;


float map(in vec3 p)
{
	float d1 = length(p) - 1.0;
	return d1;
}

vec3 calcNormal(in vec3 p) 
{
	vec2 e = vec2(0.0001, 0.0);
	return normalize(vec3(
						map(p+e.xyy) - map(p-e.xyy),
						map(p+e.yxy) - map(p-e.yxy),
						map(p+e.yyx) - map(p-e.yyx)
					));
}

vec3 sobel(vec2 st)
{
	vec3 col = vec3(0.0);

	col += tex(INPUT, st + vec2(-texel, -texel);
	col += tex(INPUT, st + vec2(-texel, 0.0);
	col += tex(INPUT, st + vec2(-texel, texel);
	col += tex(INPUT, st + vec2(0.0, -texel);
	col += tex(INPUT, st + vec2(0.0, 0.0);
	col += tex(INPUT, st + vec2(0.0, texel);
	col += tex(INPUT, st + vec2(texel, -texel);
	col += tex(INPUT, st + vec2(texel, 0.0);
	col += tex(INPUT, st + vec2(texel, texel);
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 edge = sobel(st);



	oc = h2n(hm);
}
