uniform float adsk_result_w, adsk_result_h;
uniform sampler2D Matte, adsk_results_pass1;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	float matte = texture2D(Matte, st).r;

	gl_FragColor = vec4(matte);
}
