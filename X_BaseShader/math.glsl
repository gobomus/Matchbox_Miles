#version 120


uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec2 center;

void main()
{
	vec2 st = gl_FragCoord.xy / res;

	// make unnormalized center
	vec2 bc = center * res;

	// adjust for aspect ratio
	vec2 c = center;
	c.x *= adsk_result_frameratio;

	// max width of line
	// multiply max_width by distance from center to 0.0 (making line an even width as it 
	// gets closer and further away
	float max_width = 10.0;
	float mw = max_width * distance(c, vec2(0.0));

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

	c.x /= adsk_result_frameratio;

	// make center cross
	// do this back in normalized space
	if (abs(center.x - st.x) < max_width/adsk_result_w) {
		col = vec3(1.0,0.0,0.0);
	} else if (abs(center.y - st.y) < max_width/adsk_result_h) {
		col = vec3(1.0,0.0,0.0);
	}

	gl_FragColor = vec4(col, 1.0);
}
