#version 120
#extension GL_ARB_shader_texture_lod : enable

#define INPUT adsk_results_pass9
#define PALETTE adsk_results_pass2
#define GRAIN adsk_results_pass12
#define ORIG adsk_results_pass1
#define BLUR adsk_results_pass5
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

#define white vec4(1.0)
#define black vec4(0.0)
#define gray vec4(0.5)


uniform sampler2D INPUT;
uniform sampler2D PALETTE;
uniform sampler2D ORIG;
uniform sampler2D BLUR;
uniform sampler2D GRAIN;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

vec2 texel = vec2(1.0) / res;

uniform float palette_detail;
uniform bool show_palette;
uniform float palette_size;
uniform vec2 palette_pos;

uniform int blend;
uniform float mix_front;

uniform float pc_temp;
uniform float psaturation;
uniform vec3 pgain;
uniform float pgain_all;
uniform vec3 pgamma;
uniform float pgamma_all;
uniform vec3 poffset;
uniform float poffset_all;
uniform vec3 pcontrast;
uniform float pcontrast_all;




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

// Rob Moggach
vec3 color_temp(vec3 col, float temp)
{
    float t = temp + 1.0;
    col *= vec3(t, 1.0, -t + 2.0);

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

vec3 softlight(vec3 front, vec3 back) {
    bvec3 f = greaterThanEqual(front, vec3(.5));
    bvec3 b = lessThan(back, vec3(.25));

    vec3 comp = back - (1.0 - 2.0 * front) * back * (1.0 - back);
    vec3 bcomp2 = back + (2.0 * front - 1.0) * back * ((16.0 * back - 12.0) * back + 3.0);
    vec3 bcomp1 = back + (2.0 * front - 1.0) * (sqrt(back) - back);

    if (f.r) {
        comp.r = bcomp1.r;
        if (b.r) {
            comp.r = bcomp2.r;
        }
    }
   
    if (f.g) {
        comp.g = bcomp1.g;
        if (b.g) {
            comp.g = bcomp2.g;
        }
    }

    if (f.b) {
        comp.b = bcomp1.b;
        if (b.b) {
            comp.b = bcomp2.b;
        }
    }


    return comp;
}



void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT,st);
	vec3 original = tex(ORIG, st);
	float matte = texture2D(BLUR, st).a;

	 if (blend == 1) {
        col = mix(original, col, mix_front);
    } else if (blend == 2) {
        vec3 tmp = col + original;
        col = mix(col, tmp, mix_front);
    } else if (blend == 3) {
        vec3 tmp = col * original;
        col = mix(col, tmp, mix_front);
    } else if (blend == 4) {
        vec3 tmp = overlay(col, original);
        col = mix(col, tmp, mix_front);
    } else if (blend == 5) {
        vec3 tmp = softlight(col, original);
        col = mix(col, tmp, mix_front);
    } else if (blend == 6) {
        vec3 tmp = sqrt(col * col + original * original);
        col = mix(col, tmp, mix_front);
    }

	vec4 grain = texture2D(GRAIN, st);

	col += grain.rgb;

	col = color_temp(col, pc_temp);
    col = adjust_saturation(col, psaturation);
    col = adjust_gain(col, vec4(pgain, pgain_all));
    col = adjust_gamma(col, vec4(pgamma, pgamma_all));
    col = adjust_offset(col, vec4(poffset, poffset_all));
    col = adjust_contrast(col, vec4(pcontrast, pcontrast_all));

	col = make_palette(st, col);


	gl_FragColor = vec4(col, matte);
}
