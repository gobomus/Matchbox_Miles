#version 120

#define in1 Matte1
#define in2 Matte2
#define in3 Matte3
#define in4 Matte4
#define in5 Matte5
#define in6 Matte6

#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))

uniform sampler2D in1, in2, in3, in4, in5, in6, in7, in8, in9;
uniform float adsk_result_w, adsk_result_h, ratio;
uniform bool top_stack, bottom_stack;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

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
	vec3 c = vec3(0.0, 1.0, 1.0);
	vec3 m = vec3(1.0, 0.0, 1.0);
	vec3 y = vec3(1.0, 1.0, 0.0);

	vec3 outcol = vec3(0.0);

	vec3 stack1 = vec3(m1, m2, m3);
	vec3 stack2 = vec3(m4, m5, m6) + 1.0;
	stack2 = clamp(stack2, 1.000001, 2.0);

	outcol = stack1;

	if (any(greaterThan(stack2, vec3(1.000001)))) {
		outcol = max(stack1, stack2);
	}

	if (bottom_stack) {
		if (any(greaterThan(outcol, vec3(1.000001)))) {
			vec3 tmp = outcol - vec3(1.000000);
			outcol = vec3(0.0);
		}
	} else if (top_stack) {
		outcol = clamp(outcol - vec3(1.0), 0.0, 1.0);
	}


	gl_FragColor = vec4(outcol, 0.0);
}
