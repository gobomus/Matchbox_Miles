#version 120


uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec2 center;
uniform vec2 point2;


const float pi = 3.141592653589793238462643383279502884197969;

uniform float f_slider;

vec2 p1, p2, p3;
vec2 v1, v2,v3,v4;
vec3 v1v, v2v, v3v;

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
	return sqrt(v.x * v.x + v.y * v.y);
}

float is_parallel(vec3 point_from_center, vec3 coords_from_center)
{
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
	float scale_vector = 1000.0;
	float width = 20.0;

	float dot1 = 1.0 - abs(dot(normalize(point_from_center) / width, coords_from_center * scale_vector));

	return dot1;
}

void main()
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = vec3(0.0);

	p1 = center;
	p2 = point2;
	p3 = st;

	v1 = p1;
	v2 = p1 - p2;
	v2.x *= adsk_result_frameratio;
	v3 = p1 - st;
	v3.x *= adsk_result_frameratio;

	v1v = vec3(v1, 0.0);
	v2v = vec3(v2, 0.0);
	v3v = vec3(v3, 0.0);

	float para = is_parallel(v2v, v3v);
	col += blue(para);

	float perp = is_perpendicular(v2, v3);
	col += green(perp);




	gl_FragColor = vec4(col, 1.0);
}


int old_main()
{
	vec2 st = gl_FragCoord.xy / res;
	//vec2 point2 = vec2(0.0);

	// make unnormalized center
	vec2 bc = center * res;

	// trying to get the center vector to change.
	// it changes but the lines get squished. probably something
	// to do with the whole rotation matrix thing. which i don't
	// understand at all.
	vec2 c = center - point2;

	// adjust for aspect ratio
	c.x *= adsk_result_frameratio;

	// max width of line
	// multiply max_width by distance from center to 0.0 (making line an even width as it 
	// gets closer and further away, not working
	float max_width = 10.0;
	float mw = max_width * distance(c, point2);

	// use bc and gl_FragCoord.xy because there seems to be
	// floating point erros in normalized space ?
	//vec2 v1 = vec2(bc - gl_FragCoord.xy)  / mw;
	vec2 v1 = vec2(bc - gl_FragCoord.xy);

	// if dot product == 0 then vectors are perpendicular
	// if angle between vectors is less than 90 degrees, dot product it's positive
	// if angle between vectors is more than 90 degrees, dot product it's negative
	float dot1 = dot(v1,  c);
	float dot2 = 1.0 - abs(dot1);

	// Draw a line that is perpendicular to the center vector
	vec3 col = vec3(0.0);
	dot2 = smoothstep(.0, .2, dot2);
	col += vec3(0.0, dot2, 0.0);

	// this determines magnitude of vectors
	float c_mag = sqrt(c.x * c.x + c.y + c.y);
	float v_mag = sqrt(v1.x * v1.x + v1.y + v1.y);

	// I guess if the product of the 2 magnitudes is equal to the dot product
	// of the 2 vectors, the vectors are parallel. Cant get it to work.
	// if cross product is 0 they're also parallel, Can get that to work.
	// don't know why it keeps the answer in the z channel though.
	vec3 v1v = vec3(v1, 0.0);
	vec3 c1v = vec3(c, 0.0);
	vec3 cross1 = cross(c1v, v1v);

	float parallel = abs(cross1.z/mag(c));
	//float parallel = abs(cross1.z);
	parallel = 1.0 - parallel;
	parallel = smoothstep(0.0, .5, parallel);

	col += vec3(0.0, 0.0, parallel);


	col = clamp(col, 0.0, 1.0);

	// Find an angle between 2 vectors
	// works in both normalized and non-normalized coord systems
	c = center - point2;
	c.x *= adsk_result_frameratio;
	v1 = center - st;
	v1.x *= adsk_result_frameratio;

	// This returns angle in radians
	float angle = acos(dot(c,v1)/(mag(c)*mag(v1)));

	//col += vec3(0.0,  0.0, cos(angle));
	//col += vec3(0.0,  0.0, sign(cos(angle)));
	//col += vec3(0.0,  0.0, cross1.z);

	// This convert radians to degrees
	//angle *= 180.0/pi;
	// or better yet
	float deg = degrees(angle);


	//angle = cross1.z;
	//col += vec3(0.0,  angle, 0.0);

	// This changes the 1-180 degrees to 360 degrees around a circle
	// Probably a better way to acheive this
	if (cross1.z > 0.0) {
		deg = 360.0 - deg;
	}

	angle = deg;

	// View the angle analyze with a cc node to see the values go from 0 - 360
	//col += vec3(0.0,  angle, 0.0);

	// This will make you sick
	//col = vec3(0.0,  sin(angle), 0.0);

	c.x /= adsk_result_frameratio;
	v1.x /= adsk_result_frameratio;


	// Everything above here works (more or less)

	c = center;
	p2 = point2;
	v1 = c - st;

	v2 = p2 - st;
	v3 = c - p2;
	v4 = p2 - c;

	c1v = vec3(v1, 0.0);
	v1v = vec3(v3, 0.0);


	mw = length(p2 - c);

	//works
	cross1 = cross(c1v, v1v);

	if (length(v1) < length(v3) && length(v2) < length(v3) && abs(cross1.z / mag(v3)) < .01) {
			col += vec3(1.0);
	}
	//end works


	dot1 = dot(v1*100000.00, v3);

	dot2 = 1.0 - abs(dot1);
	dot2 = smoothstep(0.0, .00001, dot2);

	//col = vec3(0.0);
	if (abs(dot1) < 100) {
		//col = vec3(0.0,0.0,dot1);
	}




	// make center cross
	if (abs(center.x - st.x) < max_width/adsk_result_w) {
		col = vec3(1.0,0.0,0.0);
	} else if (abs(center.y - st.y) < max_width/adsk_result_h) {
		col = vec3(1.0,0.0,0.0);
	}



	c.x /= adsk_result_frameratio;


	gl_FragColor = vec4(col, 1.0);

	return 1;
}
