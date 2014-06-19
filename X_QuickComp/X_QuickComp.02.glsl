#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);


uniform vec3 translation_amount;

uniform float persp_amnt;
uniform vec3 rotation_amount;
float x_rotation = rotation_amount.x;
float y_rotation = rotation_amount.y;
float z_rotation = rotation_amount.z;

uniform vec2 perspective_position;
float x_persp_pos = perspective_position.x;
float y_persp_pos = perspective_position.y;

uniform vec3 scale_amount;

uniform vec3 shear_amount;

uniform vec3 angle3D;

uniform float near;

uniform sampler2D adsk_results_pass1;
uniform sampler2D Back;

uniform float transparency;

uniform bool front_premult;


uniform vec2 center;

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}


mat3 shear(vec3 shear_amount)
{
	mat3 shear_matrix = mat3(
                        	1.0, 				-shear_amount.x, 	0.0,
                        	-shear_amount.y, 	1.0, 				0.0,
							0.0,				-shear_amount.z,	1.0
                    	);

	return shear_matrix;
}

mat3 scale(vec3 scale_amount)
{
	mat3 scale_matrix = mat3(
							abs(1.0 - scale_amount.x), 	0.0, 						0.0,
							0.0,						abs(1.0 - scale_amount.y), 	0.0,
							0.0,						0.0,						1.0 + scale_amount.z
							);

	return scale_matrix;
}

mat3 rotate_z(float rotation_amount)
{
	mat3 rotation_matrix = mat3(
								cos(-rotation_amount), -sin(-rotation_amount), 	0.0,
								sin(-rotation_amount), cos(-rotation_amount), 	0.0,
								0.0,			0.0,		  					1.0
								);

	return rotation_matrix;
}

mat3 rotate_y(float rotation_amount)
{
	mat3 rotation_matrix = mat3(
               		1.0 + abs(rotation_amount * persp_amnt) * 2.0, 	0.0, x_persp_pos,
               		0.0,											1.0, 0.0,
               		rotation_amount,    							0.0, 1.0
                	);

	return rotation_matrix;
}

mat3 rotate_x(float rotation_amount)
{
	mat3 rotation_matrix = mat3(
                	1.0, 0.0, 											0.0,
                	0.0, 1.0 + abs(rotation_amount * persp_amnt) * 2.0, 	y_persp_pos,
                	0.0, rotation_amount,       							1.0 
                	);

	return rotation_matrix;
}

mat3 translate(vec3 translation_amount)
{
	mat3 translation_matrix = mat3(
									1.0, 0.0, -translation_amount.x + .5,
									0.0, 1.0, -translation_amount.y + .5,
									0.0, 0.0, 1.0 + translation_amount.z
								);

	return translation_matrix;
}

vec2 apply_transformations(vec2 coords, vec2 center, mat3 transformation_matrix, int ratio)
{

	coords -= center;
	if (ratio > 0) {
   		coords.x *= adsk_result_frameratio;
	}

	vec3 tmp_vec = vec3(coords, 1.0);
   	tmp_vec *= transformation_matrix;

    coords.x = tmp_vec.x / tmp_vec.z;
    coords.y = tmp_vec.y / tmp_vec.z;

	if (ratio > 0) {
   		coords.x /= adsk_result_frameratio;
	}

   	coords += center;

	return coords;
}

void main(void)
{
    vec2 st = gl_FragCoord.xy / res;

	vec4 front = vec4(0.0);
    vec4 back = texture2D(Back, st);

	// Default postion
	mat3 t_matrix = mat3(
						1.0, 0.0, 0.0,
						0.0, 1.0, 0.0,
						0.0, 0.0, 1.0
						);

	t_matrix *= translate(translation_amount);
	st = apply_transformations(st, center, t_matrix, 0);

	t_matrix = rotate_x(x_rotation);
	t_matrix *= rotate_y(y_rotation);
	t_matrix *= rotate_z(z_rotation);
	t_matrix *= scale(scale_amount);
	t_matrix *= shear(shear_amount);

	st = apply_transformations(st, center,  t_matrix, 1);

	if (isInTex(st)) {
    	front = texture2D(adsk_results_pass1, st);
	}

	float matte = front.a * (1.0 - transparency);
	vec4 comp = front * matte + back * (1.0 - matte);

	if (front_premult) {
		comp = front + back * (1.0 - matte);
	}


    gl_FragColor = vec4(comp.rgb, front.a);
}
