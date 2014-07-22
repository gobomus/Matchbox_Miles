#version 120

uniform float adsk_result_frameratio;

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);


//uniform vec2 l, t, r;


vec2 resolution = vec2(adsk_result_w, adsk_result_h);

void main( void ) {
	vec2 st = gl_FragCoord.xy / resolution.xy;

	vec2 l = vec2(.2);
	vec2 r = vec2(.8,.2);
	vec2 t = vec2(.5, .8);

	vec2 v0 = t - l;
	vec2 v1 = r - l;
	vec2 v2 = st - l;

	float dot00 = dot(v0, v0);
	float dot01 = dot(v0, v1);
	float dot02 = dot(v0, v2);
	float dot11 = dot(v1, v1);
	float dot12 = dot(v1, v2);

	float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
	float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	float col = 0.0;

	if (u >= 0 && v >= 0 && u + v <= 1) {
		if (v < .001) {
			col = smoothstep(0.0, .001, v);
		} else if (u + v > .999) {
			col = smoothstep(1.0, .999, u+v);
		} else {
			col = 1.0;
		}

		col = 1.0;
	} else {
		col = u + v;
	}

	gl_FragColor = vec4(col);
}
