#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform float circle_radius;
uniform vec2 center;
uniform float softness;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec2 center_offset = center;

	st.x *= adsk_result_frameratio;
	center_offset.x *= adsk_result_frameratio;

	float dist = length(st - center_offset);
	float circle = smoothstep(circle_radius, circle_radius+softness*.005, dist);

	gl_FragColor = vec4(1.0 - circle);
}
