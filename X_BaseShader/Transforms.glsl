#version 120

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 translate(vec2 st, vec2 center, vec2 position)
{
	return (st - position) + center;

}

vec2 uniform_scale(vec2 st, vec2 center, float scale) 
{
	vec2 ss = vec2(scale / vec2(100.0));

	return (st - center) / ss + center;
}

vec2 rotate(vec2 coords, vec2 center, float rotation)
{
	mat2 rotation_matrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

   	coords -= center;
   	coords.x *= adsk_result_frameratio;
   	coords *= rotation_matrice;
   	coords.x /= adsk_result_frameratio;
   	coords += center;

	return coords;
}

vec2 shear(vec2 coords, vec2 center, vec2 shear)
{
	mat2 shear_matrix = mat2(
                        1.0, shear.x, // st.x = st.x * 1.0 + st.y * shear.x
                        shear.y, 1.0 // st.y = st.x * shear.y + st.y * 1.0
                    );

	coords -= center;
   	coords.x *= adsk_result_frameratio;
   	coords *= shear_matrix;
   	coords.x /= adsk_result_frameratio;
   	coords += center;

	return coords;
}

vec2 swivel(vec2 coords, vec2 center, vec2 swivel_val)
{
	mat3 m_mat = mat3(
                1-(-abs(swivel_val*.5))*2, 0,0,
                0,1,0,
                swivel_val,    0,1
                );

    coords -= center;

    vec3 bla = vec3(coords, 1);

    bla *= m_mat;

    coords.x = bla.x/bla.z;
    coords.y = bla.y/bla.z;

    coords += center;

	return coords;
}

vec2 tilt(vec2 coords, vec2, center, vec2 tilt)
{
	mat3 m_mat = mat3(
                1, 0,0,
                0,  1-(-abs(tilt*.5))*2,0,
                0,  tilt,       1       
                );

	coords -= center;

    vec3 bla = vec3(coords, 1);

    bla *= m_mat;

    coords.x = bla.x/bla.z;
    coords.y = bla.y/bla.z;

    coords += center;

	return coords;
}

vec2 barrel_distort(vec2 coords, vec2 center, float barrel)
{
	vec2 cc = coords - center;
	float dist = dot(cc, cc);
	coords = coords + cc * dist * barrel;

	return coords;
}

