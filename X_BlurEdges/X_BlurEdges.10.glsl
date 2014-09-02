#version 120

uniform sampler2D adsk_results_pass7, adsk_results_pass6, adsk_results_pass9;
uniform float adsk_result_w, adsk_result_h;
uniform float edge_strength;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = texture2D(adsk_results_pass7, st);
	vec4 blurred_edge = texture2D(adsk_results_pass6, st);
	vec4 blurred_front = texture2D(adsk_results_pass9, st);

	vec4 comp = blurred_front * blurred_edge + front * (1.0 - blurred_edge);

	gl_FragColor = vec4(comp.rgb, blurred_edge.r);
}
