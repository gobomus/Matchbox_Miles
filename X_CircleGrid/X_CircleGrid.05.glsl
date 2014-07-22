#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass4;

uniform float rotation;
uniform float scale;
// float scale = 25;

vec2 center = vec2(.5);

vec2 unalign(vec2 st) {
    st += center;
    st.x /= adsk_result_frameratio;

    return st;
}

vec2 align(vec2 st) {
    st -= center;
    st.x *= adsk_result_frameratio;

    return st;
}

vec2 uniform_scale(vec2 st)
{
	st = align(st);
	st = st / (scale / 100.0);
	st = unalign(st);

    return st;
}

vec2 rotate(vec2 st) {
	st = align(st);
	mat2 rotationMatrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );
	st *= rotationMatrice;
	st = unalign(st);

	return st;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	st = uniform_scale(st);
	st = rotate(st);

	vec4 grid = texture2D(adsk_results_pass4, st);

	gl_FragColor = grid;
}
