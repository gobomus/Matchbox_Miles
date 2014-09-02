uniform float adsk_result_w, adsk_result_h;
uniform sampler2D WarpStrength;

void main()
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 warper = texture2D(WarpStrength, st);

	gl_FragColor = warper;
}
