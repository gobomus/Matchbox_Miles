#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform float rotate;

#extension GL_ARB_shader_texture_lod : enable

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(.5);

	mat2 r_matrix = mat2( cos(rotate), sin(rotate), -sin(rotate), cos(rotate) ); 

	st -= center;
	st.x *= adsk_result_frameratio;
	st *= r_matrix ;
	st.x /= adsk_result_frameratio;
	st += center;

	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 0.0);
}
