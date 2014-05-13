uniform sampler2D FrontMatte;
uniform sampler2D BackMatte;
uniform float adsk_result_w, adsk_result_h;
uniform bool swap_inputs;
uniform bool result;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front_matte = clamp(texture2D(FrontMatte, st), 0.0, 1.0);
	vec4 back_matte = clamp(texture2D(BackMatte, st), 0.0, 1.0);
	vec4 color = front_matte + back_matte - 2.0 * front_matte * back_matte;

	if (result) {
		gl_FragColor = clamp(front_matte * back_matte, 0.0, 1.0);
	} else {
		gl_FragColor = clamp(color, 0.0, 1.0);
	}
}
