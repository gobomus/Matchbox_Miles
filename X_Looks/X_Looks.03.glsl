#version 120

#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))
#define tex(col, coords) texture2D(col, coords).rgb

#define pi 3.141592653589793238462643383279502884197969

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

//Input Image's gamma
uniform float GAMMA;

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
uniform float shiftr, rfo, rs;
uniform float shiftg, gfo, gs;
uniform float shiftb, bfo, bs;
uniform float shiftc, cfo, cs;
uniform float shiftm, mfo, ms;
uniform float shifty, yfo, ys;

// FX
uniform float glow_threshold;

vec3 adjust_gain(vec3 col, vec4 gai)
{
	vec3 g = gai.rgb * vec3(gai.a);
	col = g.rgb * col;

	return col;
}

vec3 adjust_gamma(vec3 col, vec4 gam)
{
	vec3 g = gam.rgb * vec3(gam.a);
	col.r = pow(col.r, 1.0 / g.r);
	col.g = pow(col.g, 1.0 / g.g);
	col.b = pow(col.b, 1.0 / g.b);

	return col;
}

vec3 adjust_offset(vec3 col, vec4 offs)
{
	vec3 o = offs.rgb * vec3(offs.a);
	vec3 tmp = col - vec3(1.0);

	col = mix(col, tmp, 1.0 - o);

	return col;
}

vec3 adjust_contrast(vec3 col, vec4 con)
{
	vec3 c = con.rgb * vec3(con.a);
	vec3 t = (vec3(1.0) - c) / vec3(2.0);
	t = vec3(.18);

	col = (1.0 - c.rgb) * t + c.rgb * col;

	return col;
}

vec3 adjust_saturation(vec3 col, float c)
{
    float l = luma(col);
    col = (1.0 - c) * l + c * col;

    return col;
}


vec3 toyiq(vec3 col)
{
    mat3 ym = mat3(
        .299, .587, .114,
        .596, -.274, -.321,
        .211, -.523, .311
    );

    col *= ym;

    return col;
}

vec3 fromyiq(vec3 col)
{
    mat3 rm = mat3(
        1.0, .956, .621,
        1.0, -.272, -.647,
        1.0, -1.107, 1.705
    );

    col *= rm;

    return col;
}

vec3 rhue(vec3 col, float r)
{
    float rmult = 180.0;

    mat3 hm = mat3(
        1.0,    0.0,    0.0,
        0.0,    cos(r * pi / rmult),    -sin(r * pi / rmult),
        0.0,    sin(r * pi / rmult),    cos(r * pi / rmult)
    );

    col *= hm;

    return col;
}

float get_hue(vec3 col)
{
    col = clamp(col, 0.0, 1.0);

    //compute hue from rgb ... Damn cool
    float h = atan(sqrt(3.0) * (col.g - col.b), 2.0 * col.r - col.g - col.b);
    h = degrees(h);
    if (h < 0.0) {
        h += 360.0;
    }

    return h;
}

vec3 hue_shift(vec3 col, float the_hue, float shift, float fo)
{
    float in_g = 1.0;

    float th = 360 - the_hue;
    float dif = -(th - 180.0);

    col = toyiq(col);
    col = rhue(col, dif);
    th += dif;
    col = fromyiq(col);

    float h = get_hue(col);
    col = toyiq(col);

    float s = 0.0;

    if (h > th) {
        s = (1.0 - smoothstep(th, th + fo, h)) * shift;
    } else {
        s = smoothstep(th - fo, th, h) * shift;
    }

    col = rhue(col, s);
    col = rhue(col, -dif);
    col = fromyiq(col);

    return col;
}

vec3 shift_hue(
	vec3 col,
	float sr, float sy, float sg, float sc, float sb, float sm,
	float fr, float fy, float fg, float fc, float fb, float fm
)
{
	vec3 hues[] = vec3[](
        vec3(0.0, -sr, fr),
        vec3(60.0, -sy, fy),
        vec3(120.0, -sg, fg),
        vec3(180.0, -sc, fc),
        vec3(240.0, -sb, fb),
        vec3(300.0, -sm, fm)
    );

    for (int i = 0; i < 6; i++) {
        col = hue_shift(col, hues[i].r, hues[i].g, hues[i].b);
    }

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
	
	//col = pow(col, vec3(GAMMA));

	float glow_t = glow_threshold;

	float i_saturation = 1.0;
	vec4 i_gamma = vec4(1.0);
	vec4 i_gain = vec4(1.0);
	vec4 i_contrast = vec4(1.0);

	if (look == 1) {
		// Bleach Bypass
		i_saturation = .3;
		i_gamma = vec4(1.0, 1.0, 1.0, .4);
		i_gain = vec4(1.0, 1.0, 1.0, 1.1);
	} else if (look == 2) {
		// Sepia 
		i_saturation = 0.0;
		i_gamma = vec4(1.0, .627, .329, 1.28);
		i_gain = vec4(.98, .992, .729, 1.77);
		i_contrast.w = 1.16;
	} else if (look == 3) {
		// Sepia 2
		i_saturation = 0.0;
		i_gamma = vec4(1.0, .627, .329, 1.28);
		i_gain = vec4(.98, .992, .729, 1.77);
		i_contrast.w = 1.16;
	} else if (look == 6) {
		vec3 red = vec3(col.r) * vec3(1.0, 0.0, 0.0);
		vec3 green = vec3(col.g) * vec3(0.0, 1.0, 0.0);
		vec3 blue = vec3(col.g) * vec3(0.0, 0.0, 1.0);

		col = red + green + blue;
		i_saturation = 1.4;
	} else if (look == 7) {
		// Infrared
		vec3 red = vec3(0.0);
		vec3 green = vec3(0.0);
		vec3 blue = vec3(0.0);

		blue = vec3(col.bbb);

		//i_gamma.w = 1.5;
		//i_contrast.w = 2.0;

		red = vec3(col.rrr);

		vec3 minusblue = red - blue;

		col = minusblue;
	}

	col = color_temp(col, c_temp);
	col = adjust_gamma(col, vec4(gamma, gamma_all) * i_gamma);
	col = adjust_saturation(col, saturation * i_saturation);
	col = adjust_gain(col, vec4(gain, gain_all) * i_gain);
	col = adjust_offset(col, vec4(offset_, offset_all));
	col = adjust_contrast(col, vec4(contrast, contrast_all) * i_contrast);
	col = shift_hue(col, shiftr, shifty, shiftg, shiftc, shiftb, shiftm, rfo, yfo, gfo, cfo, bfo, mfo);

	// Collect a matte to use in later passes for glows
	float matte_out = 0.0;
	float front_l = luma(col);
	matte_out = step(glow_t, front_l);

	gl_FragColor = vec4(col, matte_out);
}
