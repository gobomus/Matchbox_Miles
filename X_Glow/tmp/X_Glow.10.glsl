#version 120

#define O adsk_results_pass1
#define BACK adsk_results_pass2
#define T adsk_results_pass3
#define R adsk_results_pass5
#define G adsk_results_pass7
#define B adsk_results_pass9
#define INPUT adsk_results_pass6
#define tex(col, coords) texture2D(col, coords).rgb
#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

//http://www.ananasmurska.org/tools/PhotoshopMathFP.glsl
#define boverlay(base, blend)    (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define bsoftlight(base, blend)  ((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define hypot(base, blend) (sqrt(base * base + blend * blend))
#define screen(base, blend)         (1.0 - ((1.0 - base) * (1.0 - blend)))

uniform sampler2D O, T, R, G, B, INPUT, BACK;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float th;
uniform float blur_amount;
uniform float blend;
uniform bool show_t;
uniform float scale_source;
uniform float noise_b;
uniform float noise_scale;
uniform bool add_noise;
uniform int blend_mode;
uniform float saturation;

vec3 adjust_saturation(vec3 col, float c)
{
    float l = luma(col);
    col = (1.0 - c) * l + c * col;

    return col;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 back = tex(BACK, st);
	float r = texture2D(R, st).r;
	float g = texture2D(G, st).g;
	float b = texture2D(B, st).b;
	vec3 col = vec3(r,g,b);

	float bl = -blend;
	bl += 1.0;

	if (add_noise) {
		vec2 c = st;
		c -= vec2(.5);
		c /= vec2(1.0 - noise_scale);
		c += vec2(.5);

		float noise = texture2D(BACK, c / noise_scale).a;

		col = mix(col, col*noise, noise_b);
	}

	col = adjust_saturation(col, saturation);

	vec3 orig = vec3(0.0);
	col = mix(col, orig, bl);
	orig = tex(O, st);
	orig = mix(vec3(0.0), orig, scale_source);
	
	if (blend_mode == 0) {
		col = screen(orig, col);
	} else if (blend_mode == 1) {
		col = hypot(orig, col);
	} else if (blend_mode == 2) {
		col += orig;
	} else if (blend_mode == 3) {
		col.r = boverlay(orig.r, col.r);
		col.g = boverlay(orig.g, col.g);
		col.b = boverlay(orig.b, col.b);
	} else if (blend_mode == 4) {
		col.r = bsoftlight(orig.r, col.r);
		col.g = bsoftlight(orig.g, col.g);
		col.b = bsoftlight(orig.b, col.b);
	} else if (blend_mode == 5) {
		col *= orig;
	}

	if (show_t) {
		col = tex(T, st);
	}

	gl_FragColor = vec4(col, 1.0);
}
