#version 120


uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec2 center;
uniform vec2 point2;


const float pi = 3.141592653589793238462643383279502884197969;

uniform float f_slider;

//vec2 p1, p2, p3;
//vec2 v1, v2,v3,v4;
//vec3 v1v, v2v, v3v;

float smooth = .1;

vec3 red(float r)
{
	vec3 col =  vec3(r, 0.0, 0.0);
	col = smoothstep(0.0, smooth, col);

	return col;
}

vec3 green(float g)
{
	vec3 col = vec3(0.0, g, 0.0);
	col = smoothstep(0.0, smooth, col);

	return col;
}

vec3 blue(float b)
{
	vec3 col = vec3(0.0, 0.0, b);
	col = smoothstep(0.0, smooth, col);

	return col;
}

float mag(vec2 v) {
	// find the magnitude of a vector
	return sqrt(v.x * v.x + v.y * v.y);
}

float is_parallel(vec3 point_from_center, vec3 coords_from_center)
{
	// the cross product will return 0 if parallel and
	// gets further away from 0 as it gets less paralell
	// scale the vector so the cross product can be visualized sharper
	float scale_vector = 1000.0;

	// by dividing the normalized vector by width we get scale the
	// vector back. The close the vector is to the other one. The
	// value of the cross product gets broader
	float width = 20.0;

	// The z channel of the cross product holds the answer
	// Not sure why
	float para = 1.0 - abs(cross(normalize(point_from_center) / width, coords_from_center * scale_vector).z);

	return para;
}

float is_perpendicular(vec2 point_from_center, vec2 coords_from_center)
{
	// the dot product will return 0 if perpendicular and gets
	// further away from 0 the less perpendicular
	float scale_vector = 1000.0;
	float width = 20.0;

	float dot1 = 1.0 - abs(dot(normalize(point_from_center) / width, coords_from_center * scale_vector));

	return dot1;
}

float draw_cross(vec3 center_vector, vec3 coords_from_center)
{

	float col = is_parallel(center_vector, coords_from_center);

	col = clamp(col, 0.0, 1.0);


	return col;

}

bool draw_a_line(vec2 v1, vec2 v2, vec2 v3, vec2 v4)
{
	if (length(v3) < length(v2) && length(v4) < length(v2)) {
			return true;
	} else {
		return false;
	}
}

float get_angle(vec2 center_to_point2, vec2 coords_from_center)
{
	float angle = acos(dot(center_to_point2, coords_from_center) / (mag(center_to_point2) * mag(coords_from_center)));

	return angle;
}

void main()
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = vec3(0.0);

	vec2 p1 = center;
	vec2 p2 = point2;
	vec2 p3 = st;

	vec2 v1 = p1;
	vec2 v2 = p1 - p2; // make vector from center point to point2
	v2.x *= adsk_result_frameratio;
	vec2 v3 = p1 - p3; // make vector from center point to current coords
	v3.x *= adsk_result_frameratio;
	vec2 v4 = p2 - p3;
	v4.x *= adsk_result_frameratio;

	// make xyz vectors to use in cross product operations
	vec3 v1v = vec3(v1, 0.0);
	vec3 v2v = vec3(v2, 0.0);
	vec3 v3v = vec3(v3, 0.0);

	float para = is_parallel(v2v, v3v);
	col += blue(para);

	float perp = is_perpendicular(v2, v3);
	col += green(perp);


	// draw center cross
	vec3 center_offset = vec3(v1v - vec3(0.0, v1v.y, 0.0));
	float center_cross = draw_cross(v1v - center_offset, v3v);

	center_offset = vec3(v1v - vec3(v1v.x, 0.0, 0.0));
	center_cross += draw_cross(v1v - center_offset, v3v);
	col += red(center_cross);

	if (draw_a_line(v1, v2, v3, v4)) {
		col += red(para);
	}

	// Find the angle between 2 vectors
	float angle_in_radians = get_angle(v2, v3);
	float angle_in_degrees = degrees(angle_in_radians);

	// This changes the 1-180 degrees to 360 degrees around a circle
	// Probably a better way to acheive this
	if (cross(v2v, v3v).z < 0.0) {
		angle_in_degrees = 360.0 - angle_in_degrees;
	}

	// View the angle analyze with a cc node to see the values go from 0 - 360
	//col = vec3(0.0, 0.0, angle_in_degrees);

	gl_FragColor = vec4(col, 1.0);
}
