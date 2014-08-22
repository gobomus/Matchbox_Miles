#version 120

#define INPUT Front
#define tex(col, coords) texture2D(col, coords).rgb


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float contrast;
uniform float input_gamma;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);
	float inverted_gamma = 1.0 / input_gamma;

	vec3 gray = vec3(.5);

	col = pow(col, vec3(input_gamma));
	col = mix(gray, col, contrast);
	col = pow(col, vec3(inverted_gamma));

	col = clamp(col, 0.0, 1.0);

	gl_FragColor = vec4(col, 0.0);
}
