#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1;
uniform sampler2D adsk_results_pass2;
uniform sampler2D adsk_results_pass3;
uniform sampler2D adsk_results_pass4;
uniform sampler2D adsk_results_pass7;

uniform bool keep_aspect;
uniform vec2 s2;



void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec2 coords = st;
	coords.x /= adsk_result_frameratio;
	vec4 grid = texture2D(adsk_results_pass7, coords);


	gl_FragColor = grid;
}
