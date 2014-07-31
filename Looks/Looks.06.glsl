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

uniform sampler2D INPUT;
uniform sampler2D ORIG;
uniform sampler2D BLUR;
uniform sampler2D PALETTE;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform int look;
uniform float palette_detail;
uniform bool show_palette;
uniform float palette_size;
uniform vec2 palette_pos;

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

vec3 i_glow_gamma = vec3(1.0);
float i_glow_gamma_all = 1.0;

vec3 i_post_gamma = vec3(1.0);
float i_post_gamma_all = 1.0;
vec3 i_post_gain = vec3(1.0);
float i_post_gain_all = 1.0;
vec3 i_post_contrast = vec3(1.0);
float i_post_contrast_all = 1.0;
vec3 i_post_offset = vec3(1.0);
float i_post_offset_all = 1.0;
float i_post_saturation = 1.0;

vec3 i_vinette_gamma = vec3(1.0);
float i_vinette_gamma_all = 1.0;
vec3 i_vinette_gain = vec3(1.0);
float i_vinette_gain_all = 1.0;

bool isInTex( const vec2 coords )
{
   return coords.x >= 0.0 && coords.x <= 1.0 &&
          coords.y >= 0.0 && coords.y <= 1.0;
}

//PALETTE
vec3 make_palette(vec2 st, vec3 col)
{
    vec4 palette = vec4(0.0);
    vec2 coords = st;

    if (show_palette) {
        vec2 coords = st;
        coords -= palette_pos;
        coords /= vec2(palette_size);

        if (isInTex(coords)) {
            palette = texture2DLod(PALETTE, coords , palette_detail);

            float thresh = .009;
            if (palette.r < thresh && palette.g < thresh && palette.b < thresh) {
                palette.rgb = black.rgb;
            }

            thresh = .93;
            if (palette.r > thresh && palette.g > thresh && palette.b > thresh) {
                palette.rgb = white.rgb;
            }

            palette = clamp(palette, 0.0, 1.0);
            palette.a = 1.0;
        }

    }

	col = clamp(col, 0.0, 1.0);
	col = mix(col, palette.rgb, palette.a);


    return col;
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

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 source = tex(INPUT, st);

	vec4 blur = texture2D(BLUR, st);
	float matte = blur.a;

	vec3 col = source;

	if (look == 1) {
		i_post_gamma_all = 1.15;
		i_post_gain_all = 1.15;
	} else if (look == 2) {
	      i_post_gamma_all = 1.84;
	      i_post_gain_all = 1.25;
	      i_post_saturation = .82;
	} else if (look == 3) {
		i_post_saturation = .85;
		i_glow_gamma_all = 1.2;
	} else if (look == 4) {
		i_glow_gamma = vec3(1.0, .68, 1.562);
		col = adjust_glow(col, vec4(i_glow_gamma, 1.0), blur, true);
	}

	float saturation_bundle = post_saturation * i_post_saturation;
	vec4 gain_bundle = vec4(post_gain * i_post_gain, post_gain_all * i_post_gain_all);
	vec4 gamma_bundle = vec4(post_gamma * i_post_gamma, post_gamma_all * i_post_gamma_all);
	vec4 offset_bundle = vec4(post_offset * i_post_offset, post_offset_all * i_post_offset_all);
	vec4 contrast_bundle = vec4(post_contrast * i_post_contrast, post_contrast_all * i_post_contrast_all);
	vec4 vinette_gamma_bundle = vec4(vinette_gamma * i_vinette_gamma, vinette_gamma_all * i_vinette_gamma_all);
	vec4 vinette_gain_bundle = vec4(vinette_gain * i_vinette_gain, vinette_gain_all * i_vinette_gain_all);

	col = adjust_saturation(col, saturation_bundle);
    col = adjust_gain(col, gain_bundle);
    col = adjust_gamma(col, gamma_bundle);
    col = adjust_offset(col, offset_bundle);
    col = adjust_contrast(col, contrast_bundle);

	col = make_vinette(col, st, vinette_width, vinette_gain_bundle, vinette_gamma_bundle);


	col = make_palette(st, col);


	gl_FragColor = vec4(col, matte);
}
