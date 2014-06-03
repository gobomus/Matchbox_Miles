#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
float ar = adsk_result_w/adsk_result_h;

uniform sampler2D Front;

uniform float scalex, scaley, scalexy;
uniform vec2 translate;
uniform vec2 shear;
uniform float tilt;
uniform float rotatey;
uniform vec2 center;
uniform float m02, m12, m22;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec4 front = vec4(0.0);

	mat3 m_mat = mat3(
				1-scalex*2, shear.x, 	-translate.x,
				shear.y, 	1-scaley*2, -translate.y,
				rotatey, 	tilt, 		scalexy
				);

	//st.x *= adsk_result_frameratio;
	st -= center;

	vec3 bla = vec3(st, 1);

	bla *= m_mat;

	st.x = bla.x/bla.z;
	st.y = bla.y/bla.z;

	st += center;
	//st.x /= adsk_result_frameratio;

	if (isInTex(st)) {
		front = texture2D(Front, st);
	}	

	gl_FragColor = front;
}
