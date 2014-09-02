#version 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT adsk_results_pass1
#define STR adsk_results_pass2
#define BLUR adsk_results_pass4
#define tex(col, coords) texture2D(col, coords).rgb

uniform sampler2D INPUT, STR;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float width;
uniform float strength;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec4 col = texture2D(INPUT, st);
	vec4 blur = texture2DLod(INPUT, st, width);
	float str = texture2D(STR, st).r;


	col = mix(blur, col, strength * str + 1.0);


	gl_FragColor = vec4(col.rgb, blur.r);
}
