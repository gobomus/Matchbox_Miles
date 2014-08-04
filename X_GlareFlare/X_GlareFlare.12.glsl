#version 120
#extension GL_ARB_shader_texture_lod : enable

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform float saturation;

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3, adsk_results_pass4, adsk_results_pass7, adsk_results_pass8, adsk_results_pass11;

uniform int end_result;

float rand(vec2 co) {
	float seed = 10.0;
  	return fract(sin(dot(co.xy, vec2(12.9898 + seed, 78.233 - seed)) + seed) * 43758.5453);
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec3 front = texture2D(adsk_results_pass1, st).rgb;
	float matte = texture2D(adsk_results_pass3, st).r;
	vec3 flare = texture2D(adsk_results_pass11, st).rgb;
	float halo = texture2D(adsk_results_pass8, st).a;
  	float noise = rand(st) * .07;

	flare *= vec3(matte);
	//flare *= vec3(noise);

	vec3 lc = vec3(0.2125, 0.7154, 0.0721);
    vec3 flare_luma = clamp(vec3(dot(flare, lc)), 0.0, 1.0);

	flare = mix(flare_luma, flare, saturation);
	

	vec3 comp = sqrt(front * front + flare * flare);

	if (end_result == 1) {
		vec3 back = texture2D(adsk_results_pass2, st).rgb;
		comp = sqrt(back * back + flare * flare);
	} else if (end_result == 2) {
		comp = flare;
	} else if (end_result == 3) {
		comp = texture2D(adsk_results_pass4, st).rgb;
	} else if (end_result == 4) {
		comp = texture2D(adsk_results_pass7, st).rgb;
	} 

	gl_FragColor = vec4(comp, flare_luma.r);
}
