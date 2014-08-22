#version 120
#extension GL_ARB_shader_texture_lod : enable

#define ORIG adsk_results_pass1
#define PALETTE adsk_results_pass2
#define INPUT adsk_results_pass9 
#define GRAIN adsk_results_pass12
#define GLOWMATTE adsk_results_pass5

#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))
#define tex(col, coords) texture2D(col, coords).rgb

#define white vec4(1.0)
#define black vec4(0.0)

uniform int i_colorspace;

uniform int look;

uniform sampler2D INPUT;
uniform sampler2D PALETTE;
uniform sampler2D ORIG;
uniform sampler2D GLOWMATTE;
uniform sampler2D GRAIN;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float palette_detail;
uniform bool show_palette;
uniform float palette_size;
uniform vec2 palette_pos;

uniform int blend;
uniform float mix_front;

uniform float grain_hi;
uniform float grain_low;

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

vec3 adjust_cgamma(vec3 col, float gamma)
{
    col.r = pow(col.r, 1.0 / gamma);
    col.g = pow(col.g, 1.0 / gamma);
    col.b = pow(col.b, 1.0 / gamma);

    return col;
}


vec3 to_rec709(vec3 col)
{
    if (col.r < .018) {
        col.r *= 4.5;
    } else {
        col.r = (1.099 * pow(col.r, .45)) - .099;
    }

    if (col.g < .018) {
        col.g *= 4.5;
    } else {
        col.g = (1.099 * pow(col.g, .45)) - .099;
    }

    if (col.b < .018) {
        col.b *= 4.5;
    } else {
        col.b = (1.099 * pow(col.b, .45)) - .099;
    }


    return col;
}

vec3 to_sRGB(vec3 col)
{
    col.r = (1.055 * pow(col.r, 1.0 / 2.4)) - .055;
    col.g = (1.055 * pow(col.g, 1.0 / 2.4)) - .055;
    col.b = (1.055 * pow(col.b, 1.0 / 2.4)) - .055;

    return col;
}

bool isInTex( const vec2 coords )
{
   return coords.x >= 0.0 && coords.x <= 1.0 &&
          coords.y >= 0.0 && coords.y <= 1.0;
}


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


// Rob Moggach
vec3 color_temp(vec3 col, float temp)
{
    float t = temp + 1.0;
    col *= vec3(t, 1.0, -t + 2.0);

    return col;
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

    //col = clamp(col, 0.0, 1.0);
    col = mix(col, palette.rgb, palette.a);


    return col;
}

float mids(vec3 col, float more_highs, float more_lows)
{
	float highs = luma(col);
    float lows = 1.0 - highs;

    vec3 tmp  = (1.0 - smoothstep(0.5, 1.0, col));
    tmp = clamp(tmp, 0.0, 1.0);
    col = min(tmp, col);
    col = pow(col, vec3(.5));

    col = mix(col, col + vec3(highs), more_highs);
    col = mix(col, col + vec3(lows), more_lows);

    float sol = luma(col);

	return sol;
}

//http://www.ananasmurska.org/tools/PhotoshopMathFP.glsl
#define BlendOverlayf(base, blend) 	(base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define BlendSoftLightf(base, blend) 	((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define BlendHypot(base, blend) (sqrt(base * base + blend * blend))
#define BlendScreenf(base, blend) 		(1.0 - ((1.0 - base) * (1.0 - blend)))



void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT,st);
	vec3 original = tex(ORIG, st);
	float matte = texture2D(GLOWMATTE, st).a;

	vec4 grain = texture2D(GRAIN, st);

	col += grain.rgb * mids(col, grain_hi, grain_low);

	float i_pc_temp = 1.0;
	float i_saturation = 1.0;
    vec4 i_gamma = vec4(1.0);
    vec4 i_gain = vec4(1.0);
    vec4 i_offset = vec4(1.0);
    vec4 i_contrast = vec4(1.0);

    if (look == 1) {
		col *= original;
	} else if (look == 2) {
		col *= original;
	} else if (look == 3) {
        col.r = BlendOverlayf(col.r, original.r);
        col.g = BlendOverlayf(col.g, original.g);
        col.b = BlendOverlayf(col.b, original.b);
	}

	if (blend == 1) {
        col = mix(original, col, mix_front);
    } else if (blend == 2) {
        col = col + original;
    } else if (blend == 3) {
        col = col * original;
    } else if (blend == 4) {
        col.r = BlendOverlayf(col.r, original.r);
        col.g = BlendOverlayf(col.g, original.g);
        col.b = BlendOverlayf(col.b, original.b);
    } else if (blend == 5) {
        col.r = BlendSoftLightf(col.r, original.r);
        col.g = BlendSoftLightf(col.g, original.g);
        col.b = BlendSoftLightf(col.b, original.b);
    } else if (blend == 6) {
        col.r = BlendHypot(col.r, original.r);
        col.g = BlendHypot(col.g, original.g);
        col.b = BlendHypot(col.b, original.b);
    }

	col = color_temp(col, pc_temp * i_pc_temp);
    col = adjust_saturation(col, psaturation * i_saturation);
    col = adjust_gamma(col, vec4(pgamma, pgamma_all) * i_gamma);
    col = adjust_gain(col, vec4(pgain, pgain_all) * i_gain);
    col = adjust_offset(col, vec4(poffset, poffset_all) * i_offset);
    col = adjust_contrast(col, vec4(pcontrast, pcontrast_all) * i_contrast);

	if (i_colorspace == 0) {
		col = to_rec709(col);
	} else if (i_colorspace == 1) {
		col = to_sRGB(col);
	} else if (i_colorspace == 2) {
		col = adjust_cgamma(col, 1.0);
	} else if (i_colorspace == 3) {
		col = adjust_cgamma(col, 2.222222222);
	} else if (i_colorspace == 4) {
		col = adjust_cgamma(col, 1.8);
	}

	col = make_palette(st, col);

	gl_FragColor = vec4(col, matte);
}
