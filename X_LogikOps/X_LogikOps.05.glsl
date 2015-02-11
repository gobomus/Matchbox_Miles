#version 120

#define in1 adsk_results_pass3
#define in2 adsk_results_pass4
#define ratio adsk_result_frameratio

uniform sampler2D in1, in2;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform bool fpremult;
uniform bool bpremult;
uniform bool swap;

uniform int blend_mode;


//http://www.ananasmurska.org/tools/PhotoshopMathFP.glsl
#define overlay(back, front)    (back < 0.5 ? (2.0 * back * front) : (1.0 - 2.0 * (1.0 - back) * (1.0 - front)))
#define softlight(back, front)  ((front < 0.5) ? (2.0 * back * front + back * back * (1.0 - 2.0 * front)) : (sqrt(back) * (2.0 * front - 1.0) + 2.0 * back * (1.0 - front)))

#define add(font, back) back + front
#define sub(front, back) back - front
#define mult(front, back) back * front
#define div(front, back) front / back
#define hypot(front, back) (sqrt(back * back + front * front))
#define screen(back, front)         (1.0 - ((1.0 - back) * (1.0 - front)))
#define mmix(front, back, matte) front * matte + back * (1.0 - matte)
#define intersect(front, back) front + back - 2.0 * front * back


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec4 front = texture2D(in1, st);
	vec4 back = texture2D(in2, st);
	vec4 comp = vec4(0.0);
	float matte = 1.0;


	if (swap) {
		vec4 tmp = front;
		front = back;
		back = tmp;
	}

	if (blend_mode == 0) {
		if (fpremult) {
			front.a = max(front.a, .00000000000000000001);
			front.rgb /= front.a;
		}

		if (bpremult) {
			if (back.a > 0.0) {
				back.a = max(back.a, .00000000000000000001);
				back.rgb /= back.a;
			}
		}

		back.rgb *= back.a;

		comp = mix(back, front, front.a);
	} else {
		vec4 blend = vec4(0.0);
		blend.rgb = mix(back.rgb * back.a, front.rgb, front.a);
		matte = min(back.a, front.a);

		if (blend_mode == 1) {
			comp.rgb = front.rgb + back.rgb;
		} else if (blend_mode == 2) {
			comp.rgb = back.rgb - front.rgb;
		} else if (blend_mode == 3) {
			comp = mult(front, back);
		} else if (blend_mode == 4) {
			comp = div(front, back);
		} else if (blend_mode == 5) {
			comp = min(front, back);
		} else if (blend_mode == 6) {
			comp.rgb = max(front.rgb, back.rgb);
		} else if (blend_mode == 7) {
			comp = screen(back, front);
		} else if (blend_mode == 8) {
			comp = hypot(front, back);
		} else if (blend_mode == 9) {
			comp.r = softlight(back.r, front.r);
			comp.g = softlight(back.g, front.g);
			comp.b = softlight(back.b, front.b);
		}

		//comp *= matte;

		//comp = mix(blend, comp, clamp(matte, 0.0, 1.0));
		//comp = blend;
	}

/*
	back.rgb = comp.rgb * back.a;
	front.rgb = comp.rgb * front.a;
	comp = mix(back, front, front.a);
	*/

	gl_FragColor = vec4(comp.rgb, matte);
}
