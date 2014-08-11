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

#define rh  0.0
#define yh .16663
#define gh .33325
#define ch .5
#define bh -.33325
#define mh -.16663


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
uniform float c_temp;

// Hue Shifting
uniform float red_shift;
uniform float green_shift;
uniform float blue_shift;
uniform float cyan_shift;
uniform float magenta_shift;
uniform float yellow_shift;
uniform float falloff;
uniform float saturation_clip;



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

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 shift_col(vec3 source, float target, float shift_amnt, float val)
{
    vec3 col = source;
    float s = source.r;

    if (source.r > .5) {
        s = -1.0 + source.r;
        source.r = -1.0 + source.r;
    }

    source.r -= s;
    target -= s;

    float d = distance(target, abs(source.r));

    float m = 1.0 - smoothstep(0.0, .16663 * .5 + .16663, d);
    source.r += m * shift_amnt;

    source.r += s;
    col.r = source.r;

    return col;
}

// Rob Moggach
vec3 color_temp(vec3 col, float temp)
{
	float t = temp + 1.0;
    col *= vec3(t, 1.0, -t + 2.0);

	return col;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 source = tex(INPUT, st);
	vec3 col = source;
	vec3 hsv;

	float glow_t = glow_threshold;

	if (look == 1) {
		// Bleach Bypass
		col = adjust_saturation(col, .1);
		col = adjust_gamma(col, vec4(1.0, 1.0, 1.0, 1.5));
		col = adjust_contrast(col, vec4(1.0, 1.0, 1.0, 1.2));
	} else if (look == 2) {
		// Sepia
		col = adjust_saturation(col, 0.0);
		col = adjust_gain(col, vec4(.825, .768, .590, 1.14));
		col = adjust_gamma(col, vec4(.999, .479, .283, 1.67));
		col = adjust_contrast(col, vec4(1.0, 1.0, 1.0, 1.18));
	} else if (look == 3) {
		// Cross Process 1
		hsv = rgb2hsv(col);
    	hsv = shift_col(hsv, rh, .035, 1.0);
		col = hsv2rgb(hsv);
		col = adjust_saturation(col, 1.4);
		col = adjust_gain(col, vec4(.961, 1.0, 1.0, .71));
		col = adjust_gamma(col, vec4(.961, 1.0, 1.0, 1.37));
		col = adjust_offset(col, vec4(1.0, 1.0, 1.0, 1.02));
		col = adjust_contrast(col, vec4(1.914, 1.922, 1.0, 1.05));
		glow_t *= .23;
	} else if (look == 4) {
		// Purple Haze
		glow_t *= .25;
		hsv = rgb2hsv(col);
    	hsv = shift_col(hsv, rh, -.02, 1.0);
    	hsv = shift_col(hsv, gh, .22, 1.0);
    	hsv = shift_col(hsv, bh, -.1, 1.0);
		col = hsv2rgb(hsv);
	} else if (look == 5) {
		// Polaroid 669 - Yellow
		col = adjust_saturation(col, .8);
		col = adjust_gain(col, vec4(0.949, .906, .831, 1.1));
		col = adjust_gamma(col, vec4(0.979, .899, .899, 1.31));
		col = adjust_contrast(col, vec4(.925, .879, 1.0, 1.49));
		hsv = rgb2hsv(col);
    	hsv = shift_col(hsv, rh, -.01, 1.0);
    	hsv = shift_col(hsv, gh, .04, 1.0);
		col = hsv2rgb(hsv);
	} else if (look == 6) {
		// 2 strip
		vec3 red = vec3(col.r) * vec3(1.0, 0.0, 0.0);
		vec3 green = vec3(col.g) * vec3(0.0, 1.0, 0.0);
		vec3 blue = vec3(col.g) * vec3(0.0, 0.0, 1.0);

		col = red + green + blue;
		col = adjust_saturation(col, 1.4);
	} else if (look == 7) {
		// Infrared
		vec3 red = vec3(0.0);
		vec3 green = vec3(0.0);
		vec3 blue = vec3(0.0);

		blue = vec3(col.bbb);

		col = adjust_gamma(col, vec4(1.0, 1.0, 1.0, 1.5));
		col = adjust_contrast(col, vec4(1.0, 1.0, 1.0, 2.0));

		red = vec3(col.rrr);

		vec3 minusblue = red - blue;

		col = minusblue;
	} else if (look == 8) {
		// Light Yellow
		col = adjust_gain(col, vec4(1.0, 1.0, .719, 1.0));
		col = adjust_gamma(col, vec4(1.0, 1.0, 1.234, 1.0));
	}

	if (look != 0) {
		col = clamp(col, 0.0, 1.0);
	}

	col = color_temp(col, c_temp);
	col = adjust_saturation(col, saturation);
	col = adjust_gain(col, vec4(gain, gain_all));
	col = adjust_gamma(col, vec4(gamma, gamma_all));
	col = adjust_offset(col, vec4(offset_, offset_all));
	col = adjust_contrast(col, vec4(contrast, contrast_all));

	hsv = rgb2hsv(col);

    hsv = shift_col(hsv, rh, red_shift, 1.0);
    hsv = shift_col(hsv, yh, yellow_shift, 1.0);
    hsv = shift_col(hsv, gh, green_shift, 1.0);
    hsv = shift_col(hsv, ch, cyan_shift, 1.0);
    hsv = shift_col(hsv, bh, blue_shift, 1.0);
    hsv = shift_col(hsv, mh, magenta_shift, 1.0);

    col = hsv2rgb(hsv);

	//  Set Looks Transfer if any
	if (look == 1) {
		// Bleach Bypass
		col *= source;
	}

	// Collect a matte to use in later passes for glows
	float matte_out = 0.0;
	float front_l = luma(col);
	matte_out = smoothstep(glow_t, 1.0, front_l);
	matte_out = sqrt(matte_out * matte_out + matte_out * matte_out);


	gl_FragColor = vec4(col, matte_out);
}
