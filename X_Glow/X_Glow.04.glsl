#version 120

#define INPUT adsk_results_pass3
#define tex(col, coords) texture2D(col, coords).rgb
#define luma(col) dot(col, vec3(0.2126, 0.7152, 0.0722))

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float th;
uniform float gamma;
uniform vec3 color;
uniform float c;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec4 tmp = texture2D(INPUT, st);
	vec3 col = tmp.rgb;
	float l = luma(pow(col, vec3(1.0 / gamma)));


	col *= color;


	float m = step(th, l);
	m = mix(1.0 - th * 2.0, 1.0, l);
	m = clamp(m, 0.0, 1.0) ;


	col = mix(vec3(0.0), col, m);
	col = (1.0 - c) * .5 + c * col;
	col = clamp(col, 0.0, 1.0);

	gl_FragColor = vec4(col, tmp.aaa);
}
