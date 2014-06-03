#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
float ar = adsk_result_w/adsk_result_h;

uniform sampler2D Front;

uniform float angle;
uniform float near,far;
uniform float depth;

uniform float scalex, scaley, scalexy;
uniform vec2 translate;
uniform vec2 shear;
uniform float tilt;
uniform float rotatey;
uniform vec2 center;

uniform vec3 p1;
uniform vec3 p2;

uniform vec3 v11, v22,v33;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	//vec2 center = vec2(.5, .5);

	vec4 front = vec4(0.0);

	vec4 q = vec4(st,1.0,0);

	/*
	mat4 shear_mat = mat4(
						cos(angle), 0, sin(angle), 0,
						0, 1, 0, 0,
						-sin(angle), 0, cos(angle), 0,
						0, 0, 0, 1
						);
	*/


	vec3 axis = p1;


	float a = .5;
	float b = -1.0;
	float c =  0.0;

	float u2 = normalize(axis.x * axis.x);
	float v2 = normalize(axis.y * axis.y);
	float w2 = normalize(axis.z * axis.z);

	float u = axis.x;
	float v = axis.y;
	float w = axis.z;

	float m00 = u2 + (v2 + w2) * cos(angle);
	float m01 = u * v * (1.0 - cos(angle)) - w * sin(angle);
	float m02 = u * w * (1.0 - cos(angle)) + v * sin(angle);
	float m03 = (a * (v2 + w2) - u * (b * v + c * w)) * (1.0 - cos(angle));

	float m10 = u * v * (1.0 - cos(angle)) * w * sin(angle);
	float m11 = v2 + (u2 + w2) * cos(angle);
	float m12 = v * w * (1.0 - cos(angle)) - u * sin(angle);
	float m13 = (b * (u2 + w2) - v * (a * u + c * w)) * (1.0 - cos(angle));

	float m20 = u * w * (1.0 - cos(angle)) - v * sin(angle);
	float m21 = v * w * (1.0 - cos(angle)) + u * sin(angle);
	float m22 = w2 + (u2 + v2) * cos(angle);
	float m23 = (c * (u2 + v2) - w * (a * u + b * v)) * (1.0 - cos(angle));

	float m30 = 0.0;
	float m31 = 0.0;
	float m32 = 0.0;
	float m33 = 1.0;

	m00 = 1.0/(ar * tan(angle/2.0));
	m01 = 0.0;
	m02 = 0.0;
	m03 = 0.0;

	m10 = 0.0;
	m11 = 1.0/tan(angle/2.0);
	m12 = 0.0;
	m13 = 0.0;

	m20 = 0.0;
	m21 = 0.0;
	m22 = (-near -far) / (near -far);
	m23 = (2.0 * far * near) / (near -far);


	m00 = cos(angle); 
	m01 = 0.0;
	m02 = -sin(angle);
	m03 = 0.0;

	m10 = 0.0;
	m11 = 1.0;
	m12 = 0.0;
	m13 = 0.0;

	m20 = sin(angle);
	m21 = 0.0;
	m22 = cos(angle);
	m23 = 0.0;
	


	float ca = cos(angle);
	float sa = sin(angle);

	m00 = ca + u2 * (1.0 -ca);
	m01 = u*v * (1.0-ca) - w * sa;
	m02 = u*w*(1 - ca) - v * sa;

	m10 = v*u*(1 -ca) + w * sa;
	m11 = ca + v2 * (1 -ca);
	m12 = v * w * (1-ca) - u * sa;

	m20 = w * u * (1-ca) - v * sa;
	m21 = w * v * (1-ca) + u * sa;
	m22 = ca + w2 * (1- ca);


	mat3 shear_mat = mat3(
						m00, m01, m02,
						m10, m11, m12,
						m20, m21, m22
						);

	shear_mat = mat3(
					cos(angle), 0, 0,
					0, 1,0,
					angle, 0, 1
					);


	mat4 m_mat = mat4(1-scalex*2, shear.x, 0 ,-translate.x,
				shear.y, 1-scaley*2, 0 ,-translate.y,
				rotatey, tilt, scalexy ,1,
				0, 0, 0, 1);




	st.x *= adsk_result_frameratio;
	st -= center;
	vec4 bla = vec4(st, 1, 1);

	bla *= m_mat;


	st.x = bla.x/bla.z;
	st.y = bla.y/bla.z;

	st += center;
	st.x /= adsk_result_frameratio;

	if (isInTex(st)) {
		front = texture2D(Front, st);
	}	

	

	//st *= q.rg;


	gl_FragColor = front;
}
