#version 120

#define in1 Matte1
#define in2 Matte2
#define in3 Matte3
#define in4 Matte4
#define in5 Matte5
#define in6 Matte6
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))

uniform sampler2D in1, in2, in3, in4, in5, in6;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = 1.0 / res;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	float m1 = texture2D(in1, st).r;
	float m2 = texture2D(in2, st).r;
	float m3 = texture2D(in3, st).r;
	float m4 = texture2D(in4, st).r;
	float m5 = texture2D(in5, st).r;
	float m6 = texture2D(in6, st).r;

	vec3 r = vec3(1.0, 0.0, 0.0);
	vec3 g = vec3(0.0, 1.0, 0.0);
	vec3 b = vec3(0.0, 0.0, 1.0);

	vec3 col = vec3(0.0);

	col = mix(col, r, m1);
	col = mix(col, g, m2);
	col = mix(col, b, m3);
	col = mix(col, 1.0 - r, m4);
	col = mix(col, 1.0 - g, m5);
	col = mix(col, 1.0 - b, m6);

	gl_FragColor = vec4(col, 0.0);
}
