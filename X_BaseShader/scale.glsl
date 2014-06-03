#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec2 scale;
uniform bool xy_scale;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(.5);

	vec2 s = scale;
	if (xy_scale) {
		s.y = s.x;
	}

	mat2 scale_mat = mat2(
						vec2(1.0 - s.x, .0),
						vec2(0.0, 1.0 - s.y)
					);

	st -= center;
	st *= scale_mat;
	st += center;

	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 0.0);
}
