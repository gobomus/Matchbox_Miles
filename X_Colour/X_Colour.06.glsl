#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3, adsk_results_pass5;
uniform bool output_color_only;
uniform bool show_colorwheel, show_swatch;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = texture2D(adsk_results_pass1, st).rgb;
	vec4 color = texture2D(adsk_results_pass3, st);
	vec4 color_frame = texture2D(adsk_results_pass2, st);
	vec4 color_wheel = texture2D(adsk_results_pass5, st);
	
	vec3 comp = front.rgb;

	if (output_color_only) {
		comp = color_frame.rgb;
	}

	if (show_swatch) {
		comp = mix(color.rgb, comp, color.a);
	}

	if (show_colorwheel) {
		comp = mix(color_wheel.rgb, comp, color_wheel.a);
		comp = color_wheel.rgb * (1.0 - color_wheel.a) + comp * color_wheel.a;
	}

	if (output_color_only) {
		gl_FragColor = vec4(color_frame.rgb, 1.0);
	} else {
		gl_FragColor = vec4(comp, 1.0);
	}
}
