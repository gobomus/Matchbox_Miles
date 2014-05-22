#version 120


uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec2 center;
uniform vec2 point2;


const float pi = 3.141592653589793238462643383279502884197969;




float mag(vec2 v) {
	return sqrt(v.x * v.x + v.y * v.y);
}

void main()
{
	vec2 st = gl_FragCoord.xy / res;
	//vec2 point2 = vec2(0.0);

	// make unnormalized center
	vec2 bc = center * res;

	// trying to get the center vector to change.
	// it changes but the lines get squished. probably something
	// to do with the whole rotation matrix thing. which i don't
	// understand at all.
	vec2 c = point2 - center;

	// adjust for aspect ratio
	c.x *= adsk_result_frameratio;

	// max width of line
	// multiply max_width by distance from center to 0.0 (making line an even width as it 
	// gets closer and further away
	float max_width = 10.0;
	float mw = max_width * distance(c, point2);

	// use bc and gl_FragCoord.xy because there seems to be
	// floating point erros in normalized space ?
	vec2 v1 = vec2(bc - gl_FragCoord.xy)  / mw;

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

	float parallel = 1.0 - abs(cross1.z);
	parallel = smoothstep(0.0, .2, parallel);

	col += vec3(0.0, 0.0, parallel);

	col = clamp(col, 0.0, 1.0);

	// Everything above here works (more or less)


	// Find an angle between 2 vectors
	// works in both normalized and non-normalized coord systems
	c =  bc;
	v1 = vec2(bc - gl_FragCoord.xy);

	c = center;
	v1 = center - st;

	// This returns angle in radians
	float result = acos(dot(c,v1)/(mag(c)*mag(v1)));

	// This convert radians to degrees
	result *= 180.0/pi;

	col = vec3(0.0,  result, 0.0);

	// This will make you sick
	col = vec3(0.0,  sin(result), 0.0);




	// make center cross
	// do this back in normalized space
	if (abs(center.x - st.x) < max_width/adsk_result_w) {
		col = vec3(1.0,0.0,0.0);
	} else if (abs(center.y - st.y) < max_width/adsk_result_h) {
		col = vec3(1.0,0.0,0.0);
	}

	c.x /= adsk_result_frameratio;


	gl_FragColor = vec4(col, 1.0);
}
