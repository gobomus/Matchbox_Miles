#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass4;
uniform float color_wheel_size;
uniform vec2 color_wheel_pos;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	st = (st - color_wheel_pos) + vec2(0.5);
    st = (st-0.5)/(color_wheel_size/100.0)+ vec2(0.5);


	vec4 color_wheel = texture2D(adsk_results_pass4, st);

	gl_FragColor = color_wheel;
}
