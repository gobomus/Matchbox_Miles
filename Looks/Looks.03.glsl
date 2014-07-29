#version 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT adsk_results_pass1
#define PALETTE adsk_results_pass2
#define ratio adsk_result_frameratio
#define center vec2(.5)

#define white vec4(1.0)
#define black vec4(0.0)
#define gray vec4(0.5)

#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

uniform sampler2D INPUT;
uniform sampler2D PALETTE;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform int look;

// Grading
uniform vec3 gain;
uniform float gain_all;
uniform vec3 gamma;
uniform float gamma_all;
uniform vec3 offset_;
uniform float offset_all;
uniform vec3 contrast;
uniform float contrast_all;
uniform float saturation;

vec3 i_gain = vec3(1.0);
float i_gain_all = 1.0;
vec3 i_gamma = vec3(1.0);
float i_gamma_all = 1.0;
vec3 i_offset = vec3(1.0);
float i_offset_all = 1.0;
vec3 i_contrast = vec3(1.0);
float i_contrast_all = 1.0;
float i_saturation = 1.0;

// FX

uniform float glow_threshold;

bool isInTex( const vec2 coords )
{
   return coords.x >= 0.0 && coords.x <= 1.0 &&
          coords.y >= 0.0 && coords.y <= 1.0;
}


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

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 source = tex(INPUT, st);
	vec3 col = source;


	// Set Looks Grade
	if (look == 1) {
		// Bleach Bypass
		i_saturation = 0.0;
		i_gamma_all = 1.5;
	} else if (look == 2) {
		i_saturation = 0.0;
		i_gain.gb = vec2(.713, .117);
		i_gamma.rg = vec2(.833, .562);
	}

	float saturation_bundle = saturation * i_saturation;
	vec4 gain_bundle = vec4(gain * i_gain, gain_all * i_gain_all);
	vec4 gamma_bundle = vec4(gamma * i_gamma, gamma_all * i_gamma_all);
	vec4 offset_bundle = vec4(offset_ * i_offset, offset_all * i_offset_all);
	vec4 contrast_bundle = vec4(contrast * i_contrast, contrast_all * i_contrast_all);

	col = adjust_saturation(col, saturation_bundle);
	col = adjust_gain(col, gain_bundle);
	col = adjust_gamma(col, gamma_bundle);
	col = adjust_offset(col, offset_bundle);
	col = adjust_contrast(col, contrast_bundle);

	//  Set Looks Transfer if any
	if (look == 1) {
		// Bleach Bypass
		col *= source;
	}

	// Collect a matte to use in later passes for glows
	float front_l = luma(col);
	float matte_out = smoothstep(glow_threshold, 1.0, front_l);



	gl_FragColor = vec4(col, matte_out);
}
