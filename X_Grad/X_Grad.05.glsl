#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3, adsk_results_pass4;
uniform float adsk_result_frameratio;
uniform int result;
uniform bool premult;
uniform bool repeat_grad;
uniform vec2 grad_position;

vec2 translate(vec2 coords, vec2 position)
{
    return coords - position;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);
	vec2 coords = st;

	if (repeat_grad) {
		coords = translate(st, grad_position);
	}

	vec3 grad = texture2D(adsk_results_pass4, coords).rgb;

	float matte = 1.0;

	if (premult) {
		matte = texture2D(adsk_results_pass3, st).r;
	}

	grad *= vec3(matte);

	vec3 comp = grad;

	if (result == 1) {
		vec3 front = texture2D(adsk_results_pass1, st).rgb;
		comp = mix(front, grad, grad);
	} else if (result == 2) {
		vec3 front = texture2D(adsk_results_pass1, st).rgb;
		vec3 back = texture2D(adsk_results_pass2, st).rgb;
		comp = mix(back, front, grad);

	} else if (result == 3) {
		vec3 front = texture2D(adsk_results_pass1, st).rgb;
		comp = front * grad;
	}

	gl_FragColor = vec4(comp, grad.r);
}
