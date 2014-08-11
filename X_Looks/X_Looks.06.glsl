#version 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT adsk_results_pass3
#define PALETTE adsk_results_pass2
#define BLUR adsk_results_pass5
#define ORIG adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)

#define white vec4(1.0)
#define black vec4(0.0)
#define gray vec4(0.5)

#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

uniform float adsk_time;
uniform sampler2D INPUT;
uniform sampler2D ORIG;
uniform sampler2D BLUR;
uniform sampler2D PALETTE;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform int look;

// FX

uniform vec3 glow_gamma;
uniform float glow_gamma_all;
uniform bool harsh_glow;

uniform vec3 post_gamma;
uniform float post_gamma_all;
uniform vec3 post_gain;
uniform float post_gain_all;
uniform vec3 post_contrast;
uniform float post_contrast_all;
uniform vec3 post_offset;
uniform float post_offset_all;
uniform float post_saturation;

uniform bool vinette;
uniform float vinette_width;
uniform vec3 vinette_gamma;
uniform float vinette_gamma_all;
uniform vec3 vinette_gain;
uniform float vinette_gain_all;


vec3 adjust_gain(vec3 col, vec4 ga)
{
	col *= ga.rgb;
	col *= ga.a;

	return col;
}

vec3 adjust_gamma(vec3 col, vec4 gam)
{
	col = pow(col, 1.0 / gam.rgb);
	col = pow(col, vec3(1.0 / gam.a));

	return col;
}

vec3 adjust_offset(vec3 col, vec4 offs)
{
	col += offs.rgb - 1.0;
	col += offs.a - 1.0;

	return col;
}

vec3 adjust_contrast(vec3 col, vec4 con)
{
	col.r = mix(col.r, gray.r, 1.0-con.r);
	col.g = mix(col.g, gray.r, 1.0-con.g);
	col.b = mix(col.b, gray.r, 1.0-con.b);
	col = mix(col, gray.rgb, 1.0-con.a);

	return col;
}

vec3 adjust_saturation(vec3 col, float sat)
{
	col = mix(col, vec3(luma(col)), 1.0-sat);
	return col;
}

vec3 adjust_glow(vec3 col, vec4 gamma, vec4 blur, bool glow_more)
{
	if (glow_more) {
		vec3 glow = adjust_gamma(blur.rgb, gamma);
		vec3 tmp = sqrt(clamp(glow * glow,0.0, 1.0) + clamp(col * col,0.0, 1.0));
		col = mix(col, tmp, blur.a);
	} else {
		vec3 glow = adjust_gamma(col, gamma);
		col = mix(col, glow, blur.a);
	}

	return col;
}

vec3 make_vinette(vec3 col, vec2 st, float width, vec4 gain, vec4 gamma)
{
    float vinette = 0.0;
    vinette = smoothstep(0.0, width,  distance(vec2(.5), st));
    vec3 vinette_col = adjust_gamma(col, gamma);
    vinette_col = adjust_gain(vinette_col, gain);

    col = mix(col, vinette_col, vinette);

    return col;
}

vec3 overlay(vec3 front, vec3 back) {
    vec3 comp = 1.0 - 2.0 * (1.0 - front) * (1.0 - back);
    vec3 c = 1.0 - 2.0 * (1.0 - front) * (1.0 - back);

    if (back.r < .5) {
        comp.r = 2.0 * front.r * back.r;
    }

    if (back.g < .5) {
        comp.g = 2.0 * front.g * back.g;
    }

    if (back.b < .5) {
        comp.b = 2.0 * front.b * back.b;
    }

    return comp;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 source = tex(INPUT, st);
	vec3 original = tex(ORIG, st);

	vec4 blur = texture2D(BLUR, st);
	float matte = blur.a;

	vec3 col = source;

	if (look == 1) {
		//Bleach Bypass
		col = adjust_gamma(col, vec4(1.0, 1.0, 1.0, 1.15));
		col = adjust_gain(col, vec4(vec3(1.0), 1.15));
	} else if (look == 2) {
		//Sepia
		col = adjust_saturation(col, .35);
		col = adjust_gamma(col, vec4(vec3(1.0), 1.32));
		col = adjust_contrast(col, vec4(vec3(1.0), 1.21));
		col = make_vinette(col, st, vinette_width, vec4(1.0, 1.0, 1.0, .97), vec4(.307, .252, .217, 1.94));
	} else if (look == 3) {
		// Cross Processing 1
	} else if (look == 4) {
		col = adjust_glow(col, vec4(1.0, .68, 1.562, 1.0), blur, true);
	} else if (look == 5) {
		col = adjust_saturation(col, .85);
	}

	float saturation_bundle = post_saturation;
	vec4 gain_bundle = vec4(post_gain, post_gain_all);
	vec4 gamma_bundle = vec4(post_gamma, post_gamma_all);
	vec4 offset_bundle = vec4(post_offset, post_offset_all);
	vec4 contrast_bundle = vec4(post_contrast, post_contrast_all);
	vec4 vinette_gamma_bundle = vec4(vinette_gamma, vinette_gamma_all);
	vec4 vinette_gain_bundle = vec4(vinette_gain, vinette_gain_all);
	vec4 glow_bundle = vec4(glow_gamma, glow_gamma_all);

	col = adjust_glow(col, glow_bundle, blur, harsh_glow);
	col = make_vinette(col, st, vinette_width, vinette_gain_bundle, vinette_gamma_bundle);

	col = adjust_saturation(col, saturation_bundle);
    col = adjust_gain(col, gain_bundle);
    col = adjust_gamma(col, gamma_bundle);
    col = adjust_offset(col, offset_bundle);
    col = adjust_contrast(col, contrast_bundle);

	gl_FragColor = vec4(col, matte);
}
