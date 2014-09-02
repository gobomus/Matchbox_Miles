uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;
uniform float adsk_result_w, adsk_result_h;
uniform int blend;
uniform bool swap_inputs;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = texture2D(Front, st);
	vec4 back = texture2D(Back, st);
	vec4 matte = texture2D(Matte, st);

	vec4 hypot = sqrt(front * front + back * back);

	if (swap_inputs) {
		vec4 tmp = front;
		back = front;
		front = back;
	}

	vec4 comp = hypot * matte * (float(blend) / 100.0) + back * (1.0 - matte * (float(blend) / 100.0));

	gl_FragColor = comp;
}
