#version 120

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3;
uniform float adsk_result_w, adsk_result_h;
uniform int result;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = texture2D(adsk_results_pass1, st);
	vec4 comp = front;

	if (result == 1) {
		vec4 back = texture2D(adsk_results_pass2, st);
		vec4 matte = texture2D(adsk_results_pass3, st);

		comp = front * matte + back * (1.0 - matte);
	}

	gl_FragColor = comp;
}
