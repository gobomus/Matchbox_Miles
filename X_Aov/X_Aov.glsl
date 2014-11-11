#version 120

#define INPUT ID1
#define INPUT2 ID2
#define INPUT3 ID3
#define INPUT4 ID4
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT;
uniform sampler2D INPUT2;
uniform sampler2D INPUT3;
uniform sampler2D INPUT4;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform bool red, green, blue;
uniform bool red2, green2, blue2;
uniform bool red3, green3, blue3;
uniform bool red4, green4, blue4;
uniform int op1;
uniform int op2;
uniform int op3;
uniform bool neg1;
uniform bool neg2;
uniform bool neg3;
uniform bool neg4;


float make_matte(vec3 col, bool r, bool g, bool b)
{
	float m = 0.0;

	if (r) {
		m += col.r;
	}

	if (g) {
		m += col.g;
	}

	if (b) {
		m += col.b;
	}

	m = clamp(m, 0.0, 1.0);

	return m;
}

float do_op(float a1, float a2, int o)
{
	// add, 1-2, 2-1, multiply, min, max
	float m = 0.0;

	if (o == 0) {
		m = a1 + a2;
	} else if (o == 1) {
		m = a1 - a2;
	} else if (o == 2) {
		m = a2 - a1;
	} else if (o == 3) {
		m = a1 * a2;
	} else if (o == 4) {
		m = min(a1, a2);
	} else if (o == 5) {
		m = max(a1, a2);
	}

	m = clamp(m, 0.0, 1.0);

	return m;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = texture2D(INPUT, st).rgb;
	vec3 col2 = texture2D(INPUT2, st).rgb;
	vec3 col3 = texture2D(INPUT3, st).rgb;
	vec3 col4 = texture2D(INPUT4, st).rgb;

	float m1 = make_matte(col, red, green, blue);
	float m2 = make_matte(col2, red2, green2, blue2);
	float m3 = make_matte(col3, red3, green3, blue3);
	float m4 = make_matte(col4, red4, green4, blue4);

	// add, 1-2, 2-1, multiply, min, max

	float matte = m1;

	if (neg1) {
		matte = 1.0 - matte;
	}

	matte = do_op(m1, m2, op1);

	if (neg2) {
		matte = 1.0 - matte;
	}

	matte = do_op(matte, m3, op2);

	if (neg3) {
		matte = 1.0 - matte;
	}

	matte = do_op(matte, m4, op3);

	if (neg4) {
		matte = 1.0 - matte;
	}


	gl_FragColor = vec4(matte);
}
