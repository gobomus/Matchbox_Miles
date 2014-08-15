#version 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT adsk_results_pass3
#define BLUR adsk_results_pass5
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
uniform sampler2D BLUR;
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
	col.r = mix(gray.r, col.r, con.r);
    col.g = mix(gray.r, col.g, con.g);
    col.b = mix(gray.r, col.b, con.b);
    col = mix(gray.rgb, col, con.a);

	return col;
}

vec3 adjust_saturation(vec3 col, float sat)
{
	vec3 intensity = vec3(luma(col));
    col = (mix(intensity, col, sat));

	return col;
}

vec3 adjust_glow(vec3 col, vec4 gamma, vec4 blur, bool glow_more)
{
	if (glow_more) {
		vec3 glow = adjust_gamma(blur.rgb, gamma);
		vec3 tmp = sqrt(glow * glow + col * col);
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

	vec4 blur = texture2D(BLUR, st);
	float matte = blur.a;

	vec3 col = source;

	float i_saturation = 1.0;
	vec4 i_gamma = vec4(1.0);
	vec4 i_gain = vec4(1.0);
	vec4 i_offset = vec4(1.0);
	vec4 i_contrast = vec4(1.0);
	float i_vin_width = 1.0;
	vec4 i_vin_gamma = vec4(1.0);
	vec4 i_vin_gain = vec4(1.0);

	if (look == 1) {
		//Bleach Bypass
	} else if (look == 2) {
		//Sepia
		i_saturation = .75 * .61;
        i_gamma.w = 1.25 * 1.31;
		i_gain.r = 1.266;
        i_contrast.w = 1.02;
		i_vin_width = .7;
		i_vin_gamma.w = .5;
	} else if (look == 3) {
		// Sepia 2
		i_saturation = .75 * .57;
        i_gamma.w = 1.25;
		i_gain.r = 1.266;
        i_contrast.w = 1.02;
		i_vin_width = .7;
		i_vin_gamma.w = .5;
	} else if (look == 4) {
		col = adjust_glow(col, vec4(1.0, .68, 1.562, 1.0), blur, true);
	} else if (look == 5) {
		col = adjust_saturation(col, .85);
	}

	col = adjust_saturation(col, post_saturation * i_saturation);
    col = adjust_gamma(col, vec4(post_gamma, post_gamma_all) * i_gamma);
    col = adjust_gain(col, vec4(post_gain, post_gain_all) * i_gain);
    col = adjust_offset(col, vec4(post_offset, post_offset_all) * i_offset);
    col = adjust_contrast(col, vec4(post_contrast, post_contrast_all) * i_contrast);

	col = adjust_glow(col, vec4(glow_gamma, glow_gamma_all), blur, harsh_glow);
	col = make_vinette(col, st, vinette_width * i_vin_width, vec4(vinette_gain, vinette_gain_all) * i_vin_gain, vec4(vinette_gamma, vinette_gamma_all) * i_vin_gamma);

	//col = pow(col, vec3(1.0/2.2));

	gl_FragColor = vec4(col, matte);
}
