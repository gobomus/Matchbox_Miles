#version 120
#extension GL_ARB_shader_texture_lod : enable

//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define time adsk_time

#define luma(col) sqrt(dot(col * col, vec3(0.299, 0.587, 0.114)))
#define tex(col, coords) texture2D(col, coords).rgb
#define oc gl_FragColor.rgb

uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D adsk_previous_frame_Front;
uniform sampler2D dis;
uniform sampler2D Front;
uniform float time;

vec2 texel = vec2(1.0) / res;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	float scanline = gl_FragCoord.y - .5 + 1.0;

	vec3 col = normalize(tex(dis, st));

	col = (col * 2.0 - 1.0) * .035;

	col = tex(Front, st + col.xy);


	oc = col;
}
