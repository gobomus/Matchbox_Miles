#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass3, adsk_results_pass2, adsk_results_pass4, adsk_results_pass6, adsk_results_pass8;

uniform float back_flash, front_flash;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec4 front = texture2D(adsk_results_pass4, st);
	vec4 front_blur = texture2D(adsk_results_pass6, st);
	vec4 back = texture2D(adsk_results_pass2, st);
	vec4 back_blur = texture2D(adsk_results_pass8, st);
	//back_blur.rgb *= back_blur.a;

	vec4 comp = vec4(0.0);
	vec4 back_comp = vec4(0.0);

	back_blur.a *= back_flash;
	front_blur.a *= front_flash;


	comp = back_blur * back_blur.a + front * (1.0 - back_blur.a);
	back_comp = front_blur * front_blur.a + back * (1.0 - front_blur.a);
	comp = comp * front.a + back_comp * (1.0 - front.a);


	gl_FragColor = comp;
}
