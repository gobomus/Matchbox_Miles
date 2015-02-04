uniform sampler2D Front;
uniform sampler2D Matte;
uniform float adsk_result_w, adsk_result_h;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = clamp(texture2D(Front, st), 0.0, 1.0).rgb;
	float matte = clamp(texture2D(Matte, st), 0.0, 1.0).r;

	matte = clamp(matte, 0.0, 1.0);


	gl_FragColor.rgb = front * matte;
}
