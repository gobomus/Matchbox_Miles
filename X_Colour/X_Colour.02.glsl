#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1;
uniform vec2 picker;
uniform vec3 color_rgb;
uniform float adsk_result_frameratio;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 color = texture2D(adsk_results_pass1, picker).rgb;

	vec2  center = vec2(.5);
	float radius = .5;

	float ratio = adsk_result_frameratio;
	
	st.x *= ratio;
	center.x *= ratio;
	float dist = length(st - center);
	center.x /= ratio;
	st.x /= ratio;


	float alpha = clamp(radius - dist, 0.0, 1.0);
	alpha = smoothstep(0.0, .01, alpha);

	gl_FragColor = vec4(color_rgb, 1.0 - alpha);
}
