uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;
uniform float adsk_result_w, adsk_result_h;
uniform int blend;
uniform bool swap_inputs;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = clamp(texture2D(Front, st), 0.0, 1.0);
	vec4 matte = clamp(texture2D(Matte, st), 0.0, 1.0);

	gl_FragColor = clamp(front * matte, 0.0, 1.0);
}
