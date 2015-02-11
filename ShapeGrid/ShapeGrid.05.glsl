#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

#define INPUT adsk_results_pass4
uniform sampler2D INPUT;

uniform float rotation;
uniform float scale;
uniform vec2 scale_bias;

vec2 center = vec2(.5);

vec2 uniform_scale(vec2 st)
{
	st -= center;
	st = st / (vec2((scale / 100.0)) * scale_bias);
	st += center;

    return st;
}

vec2 rotate(vec2 st) {
	float r = radians(rotation);

	st -= center;
    st.x *= adsk_result_frameratio;

	mat2 rotationMatrice = mat2( cos(-r), -sin(-r), sin(-r), cos(-r) );
	st *= rotationMatrice;

    st.x /= adsk_result_frameratio;
	st += center;

	return st;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	st = rotate(st);
	st = uniform_scale(st);

	vec4 grid = texture2D(INPUT, st);

	gl_FragColor = grid;
}
