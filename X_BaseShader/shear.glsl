#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec2 shear;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(.5);

	mat2 shear_mat = mat2(
						1.0, shear.x, // st.x = st.x * 1.0 + st.y * shear.x
						shear.y, 1.0 // st.y = st.x * shear.y + st.y * 1.0
					);

	st -= center;
	st.x *= adsk_result_frameratio;
	st *= shear_mat;
	st.x /= adsk_result_frameratio;
	st += center;

	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 0.0);
}
