#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform vec2 i, n;
uniform vec3 position;

uniform sampler2D Front;

vec2 center = vec2(.5);



bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


mat3 reflect_m(vec3 coords)
{
	coords = normalize(coords);

	float u = coords.x;
	float v = coords.y;

	mat3 reflect_matrix = mat3(
								1.0 - 2.0 * (v * v), 	2.0 * u * v, 		0,
								2.0 * u * v,			-1 + 2 * (v * v), 	0,
								0.0,					0.0,				1.0
								);

	return reflect_matrix;
}

mat3 translate(vec3 translation_amount)
{
    mat3 translation_matrix = mat3(
                                    1.0, 0.0, -translation_amount.x,
                                    0.0, 1.0, -translation_amount.y,
                                    0.0, 0.0, 1.0 + translation_amount.z
                                );

    return translation_matrix;
}

vec2 apply_transformations(vec2 coords, vec2 center, mat3 transformation_matrix)
{
    coords -= center;
    coords.x *= adsk_result_frameratio;

    vec3 tmp_vec = vec3(coords, 1.0);
    tmp_vec *= transformation_matrix;

    coords.x = tmp_vec.x / tmp_vec.z;
    coords.y = tmp_vec.y / tmp_vec.z;

    coords.x /= adsk_result_frameratio;
    coords += center;

    return coords;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 front = vec3(0.0);

	mat3 t_matrix = mat3(
						1.0, 0.0, 0.0,
						0.0, 1.0, 0.0,
						0.0, 0.0, 1.0
						);

	t_matrix *= translate(position);
	vec2 coords = apply_transformations(st, center, t_matrix);


	if (isInTex(coords)) {
		front = texture2D(Front, coords).rgb;
	}

	t_matrix *= reflect_m(vec3(coords, 1));
	st = apply_transformations(st, center, t_matrix);

	if (isInTex(st)) {
		front += texture2D(Front, st).rgb;
	}
	gl_FragColor = vec4(front, 0.0);
}
