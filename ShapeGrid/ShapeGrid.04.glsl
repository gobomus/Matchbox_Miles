#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

float softness = 0.0;

uniform int sides;
uniform int num_shapes;
uniform float shape_aspect;
uniform float shape_size;
uniform vec2 shape_offset;
uniform float shape_rotation;
uniform vec3 color1;
uniform vec3 color2;
uniform bool clamp_shape;


#define center vec2(.5)
#define white vec4(1.0)
#define black vec4(0.0)

mat2 get_matrix(float angle)
{

	float r = radians(angle);

    mat2 rotationMatrice = mat2(
								 cos(r),
								-sin(r),
								 sin(r),
								 cos(r)
							);	


	return rotationMatrice;
}

vec2 bary(vec2 pos, vec2 top, vec2 left,vec2  right)
{

	top -= center;
	top.x *= shape_aspect;
	top += center;
	left -= center;
	left.x *= shape_aspect;
	left += center;
	right -= center;
	right.x *= shape_aspect;
	right += center;

	top += shape_offset;
	left += shape_offset;
	right += shape_offset;

	vec2 v0 = top - left;
    vec2 v1 = right - left;
    vec2 v2 = pos - left;

    float dot00 = dot(v0, v0);
    float dot01 = dot(v0, v1);
    float dot02 = dot(v0, v2);
    float dot11 = dot(v1, v1);
    float dot12 = dot(v1, v2);

    float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	return vec2(u,v);
}

vec2 rotate_shape(vec2 st, vec2 shape_p, float rot)
{
	shape_p -= center;
	shape_p.x *= adsk_result_frameratio;
	shape_p *= get_matrix(rot);
	shape_p.x /= adsk_result_frameratio;
	shape_p += center;

	return shape_p;
}

float draw_shape(vec2 st, vec2 top)
{
	float col = 0.0;

	//vec2 top = vec2(.5, .5 + shape_size * .5);

	//Works from here
	
	vec2 shape[60];

	shape[0] = top;
	shape[0] -= center;
	shape[0].x *= adsk_result_frameratio;

	float a;

	for (int i = 1; i <= sides; i++) {
		a = 360 / float(sides) * float(i);

		shape[i] = shape[0] * get_matrix(a);

		shape[i].x /= adsk_result_frameratio;
		//shape[i].x *= shape_aspect;
		shape[i] += center;

	}

	shape[0].x /= adsk_result_frameratio;
	shape[0] += center;

	if (sides < 3) {
		return 1.0;
	}

	float s = softness * .001;

	for (int i = 0; i < sides - 1 ; i++) {
		vec2 top = rotate_shape(st, shape[i], shape_rotation);
		vec2 left = rotate_shape(st, shape[i+1], shape_rotation);
		vec2 right = rotate_shape(st, shape[i+2], shape_rotation);

		vec2 uv = bary(st, top, left, right);

		if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x + uv.y < 1.0) {
			col += 1.0;
		}

		if (uv.x > 0.0 && uv.x < s) { // bottom side
                col *= smoothstep(0.0, s, uv.x);
            }

            if (uv.y < s && uv.y > 0.0) { // left side
                col *= smoothstep(0.0, s, uv.y);
            }

            if (uv.x + uv.y < 1.0 && uv.x + uv.y > 1.0 - s) {
                col *= 1.0 - smoothstep(1.0 - s, 1.0, uv.x + uv.y); // right size
            }


		col = clamp(col, 0.0, 1.0);

		if (sides > 4) {
			vec2 top = rotate_shape(st, center, shape_rotation);
			vec2 left = rotate_shape(st, shape[i], shape_rotation);
			vec2 right = rotate_shape(st, shape[i+2], shape_rotation);

			uv = bary(st, top, left, right);

			if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x + uv.y < 1.0) {
				col += 1.0;
			}

		col = clamp(col, 0.0, 1.0);
		}
	}



	return col;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	float shape = 0.0;
	float angle_offset = 1.0 / float(num_shapes);
	float shape_angle = 360.0 / float(sides) * angle_offset;
	vec2 top = vec2(.5, .5 + shape_size * .5);

	for (int i = 1; i <= num_shapes; i++) {
		shape += draw_shape(st, top);
		top = rotate_shape(st, top, shape_angle);
	}

	if (clamp_shape) {
		shape = clamp(shape, 0.0, 1.0);
	}

	vec3 color_out = mix(color1, color2, shape);

	gl_FragColor = vec4(color_out, shape);
}
