#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3;

uniform bool front_premultiplied; 

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec3 front = texture2D(adsk_results_pass1, st).rgb;
	float matte = texture2D(adsk_results_pass3, st).a;

	vec4 premult = vec4(front, matte);

	if (front_premultiplied) {
		vec3 back = texture2D(adsk_results_pass2, st).rgb;
		premult.rgb = premult.rgb + back * (1.0 - matte);
	}

	gl_FragColor = premult;
}
