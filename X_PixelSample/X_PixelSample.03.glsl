#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass1;
uniform float adsk_result_frameratio;

uniform vec3 picker1;
uniform vec2 picker2;
uniform int result;
uniform bool action_units;

void main(void)
{
	vec2 rez = vec2( adsk_result_w, adsk_result_h);
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec2 center = vec2(.5);
	vec4 front = texture2D(adsk_results_pass1, st);

	vec2 loc1 = picker1.xy;

	if (action_units) {
		loc1 = picker1.xy / rez - .5;
	} else {
		loc1 = picker2;
	}

	vec4 front_color1 = texture2D(adsk_results_pass2,  loc1);

	vec4 front_color = front_color1;

	if (result == 0) {
		vec2 tc = st;
		if (st.x > .9 && st.y > .9) {
			gl_FragColor = front_color;
		} else {
			gl_FragColor = front;
		}
	} else if (result == 1) {
		gl_FragColor = front_color;
	} else if (result == 2) {
		if (st.x > .9 && st.y > .9) {
			gl_FragColor = front_color;
		} else {
			gl_FragColor = texture2D(adsk_results_pass2,  st);
		}
	}
}
