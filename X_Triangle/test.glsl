#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D Front;
uniform float adsk_time;
float iGlobalTime = adsk_time;
uniform vec2 p1, p2, p3;
uniform int SIDES;
uniform float width;
uniform vec2 x1, x2, x3, x4;
uniform vec2 p;
uniform float power;
uniform float adsk_result_frameratio;
//uniform vec2 l, t, r;


vec2 resolution = vec2(adsk_result_w, adsk_result_h);

void main( void ) {
	vec2 st = gl_FragCoord.xy / resolution.xy;
	vec2 l = vec2(0.25, .1);
	vec2 r = vec2(.75,.1);

	//vec2 t = vec2(.5,.9);


	vec2 a = r - vec2(.5,.1);
	vec2 c = l;
	vec2 b = sqrt(c*c - a*a);
	vec2 t = b - l;

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

	//if (u >= 0 && v >= 0 && u + v <= 1) {
	if (u * v >= 0.0 && u + v <= 1) {
		if (v < .01) {
			col = smoothstep(0.0, .01, v);
		} else if (u + v > .99) {
			col = smoothstep(1.0, .99, u+v);
		} else {
			col = 1.0;
		}
	}


	gl_FragColor = vec4(col);
	//gl_FragColor = vec4(u,v,0.0,0.0);
}
