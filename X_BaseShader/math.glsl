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
	float max_width = 20.0;
	// multiply max_width by distance from center to 0.0 (making line an even width as it 
	// gets closer and further away
	// use bc and gl_FragCoord.xy because there seems to be
	// floating point erros in normalized space ?
	vec2 v1 = vec2(bc - gl_FragCoord.xy)  / (max_width * distance(c, vec2(0.0)));

	// if dot product == 0 then vectors are perpendicular
	// if angle between vectors is less than 90 degrees, dot product it's positive
	// if angle between vectors is more than 90 degrees, dot product it's negative
	float dot1 = dot(v1,  c);
	float dot2 = abs(dot1);

	dot2 = smoothstep(.8, 1.0, dot2);

	vec3 col = vec3(0.0);
	col += vec3(0.0, 1.0 - dot2, 0.0);

	// this determines magnitude of vectors
	float c_mag = sqrt(c.x * c.x + c.y + c.y);
	float v_mag = sqrt(v1.x * v1.x + v1.y + v1.y);

	if (c_mag * v_mag == dot1) {
		col += vec3(0.0,0.0,1.0);
	}

	c.x /= adsk_result_frameratio;

	// make center cross
	if (abs(center.x - st.x) < .002) {
		col = vec3(1.0,0.0,0.0);
	} else if (abs(center.y - st.y) < .002 * adsk_result_frameratio) {
		col = vec3(1.0,0.0,0.0);
	}

	gl_FragColor = vec4(col, 1.0);
}
