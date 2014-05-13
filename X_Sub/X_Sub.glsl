uniform sampler2D Front;
uniform sampler2D Back;
uniform float adsk_result_w, adsk_result_h;
uniform int blend;
uniform bool swap_inputs;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = clamp(texture2D(Front, st), 0.0, 1.0);
	vec4 back = clamp(texture2D(Back, st), 0.0, 1.0);

	if (swap_inputs) {
		vec4 tmp = front;
		front = back;
		back = tmp;
	}

	gl_FragColor = clamp(front - back, 0.0, 1.0);
}
