#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass3;
uniform float adsk_result_frameratio;
uniform int grad_type;
uniform float size;
uniform vec2 center;
uniform bool invert_grad;
uniform vec2 grad_offset;
uniform vec2 offset;

float pi = atan(1.0)*4.0;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);
	vec2 c = center;

	st -= grad_offset;
	float color = mod(floor(st.x), 2.0) == 0.0 ? fract(st.x) : 1.0 - fract(st.x);

	if (grad_type == 1) {
		color = mod(floor(st.y), 2.0) == 0.0 ? fract(st.y) : 1.0 - fract(st.y);
	} else if (grad_type == 2) {
		st.x *= adsk_result_frameratio;
		c.x *= adsk_result_frameratio;

		float dist = distance(c, st);

		color = 1.0 - dist / size;
	}

	if (invert_grad) {
		color = 1.0 - color;
	}

	color = clamp(color, 0.0, 1.0);

	gl_FragColor = vec4(color);
}
