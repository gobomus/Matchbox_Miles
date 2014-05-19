#version 120

uniform float adsk_result_w, adsk_result_h;
uniform sampler2D adsk_results_pass1;

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 shape = texture2D(adsk_results_pass1, st);
	vec4 col = vec4(0.0);

	if (shape.r < 1.0) {
		col = vec4(1.0);
	}


	gl_FragColor = col;
}
