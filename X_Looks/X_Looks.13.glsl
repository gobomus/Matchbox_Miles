#version 120
#extension GL_ARB_shader_texture_lod : enable

#define ORIG adsk_results_pass1
#define PALETTE adsk_results_pass2
#define INPUT adsk_results_pass9 
#define GRAIN adsk_results_pass12
#define GLOWMATTE adsk_results_pass5

#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb

#define white vec4(1.0)
#define black vec4(0.0)
#define gray vec4(0.5)

uniform float GAMMA;

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
	col.r = mix(gray.r, col.r, con.r);
    col.g = mix(gray.r, col.g, con.g);
    col.b = mix(gray.r, col.b, con.b);
    col = mix(gray.rgb, col, con.a);

    return col;
}

vec3 adjust_saturation(vec3 col, float sat)
{
	vec3 intensity = vec3(luma(col));
    col = abs(mix(intensity, col, sat));
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

    col = clamp(col, 0.0, 1.0);
    col = mix(col, palette.rgb, palette.a);


    return col;
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

	col += grain.rgb;

	float i_pc_temp = 1.0;
	float i_saturation = 1.0;
    vec4 i_gamma = vec4(1.0);
    vec4 i_gain = vec4(1.0);
    vec4 i_offset = vec4(1.0);
    vec4 i_contrast = vec4(1.0);

    if (look == 1) {
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

	col = pow(col, vec3(1.0/GAMMA));

	col = make_palette(st, col);

	gl_FragColor = vec4(col, matte);
}
