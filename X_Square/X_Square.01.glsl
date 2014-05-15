#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform vec2 square_size;
uniform vec2 center;
uniform float softness;
uniform bool uniform_square;
uniform float uniform_square_size;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec2 center_offset = center;

	st.x *= adsk_result_frameratio;
	center_offset.x *= adsk_result_frameratio;

	float s = softness * 1.0/adsk_result_w;
	vec4 square = vec4(1.0);

	vec2 s_size = square_size;

	if (uniform_square) {
		s_size = vec2(uniform_square_size);
	}

	float dist_x = length(st.x - center_offset.x);
	float col = smoothstep(s_size.x, s_size.x + s, dist_x);
	square = vec4(col);

	float dist_y = length(st.y - center_offset.y);
	col = smoothstep(s_size.y, s_size.y + s, dist_y);

	gl_FragColor = 1.0 - max(square, col);
}
