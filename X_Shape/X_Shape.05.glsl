#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass3;
//uniform vec2 center;
uniform vec2 left;
uniform vec2 top;
uniform vec2 right;
uniform float bla;

float mag(vec2 v)
{
	return sqrt(v.x * v.x + v.y * v.y);
}

void main(void)
{
	vec2 center = vec2(.5);

	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = texture2D(adsk_results_pass1, st);
	vec4 col = vec4(0.0);

	vec2 p = left;
	vec2 v = right - p;
	v /= mag(v);
	vec2 q = st;
	vec2 u = p - st;
	u /= mag(u);
	vec2 puv = (v - u) * v;
	vec2 qq = p + puv;
	float dist = mag(q - qq);

	//vec2 srv = (right - st);


	//float m1 = sqrt(lrv.x * lrv.x + lrv.y * lrv.y);
	//float m2 = sqrt(srv.x * srv.x + srv.y * srv.y);
	//float m3 = m1 * m2;
	//float d = dot(lrv, srv);

	if (dist < .5) {
		col = vec4(1.0);
	}

	gl_FragColor = col;
}
