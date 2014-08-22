#version 120

#define INPUT adsk_results_pass3
#define BLUR adsk_results_pass5

#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))
#define tex(col, coords) texture2D(col, coords).rgb

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

vec3 adjust_gain(vec3 col, vec4 gai)
{
    vec3 g = gai.rgb * vec3(gai.a);
    col = g.rgb * col;

    return col;
}

vec3 adjust_gamma(vec3 col, vec4 gam)
{
    vec3 g = gam.rgb * vec3(gam.a);
	if (col.r >= 0.0) {
    	col.r = pow(col.r, 1.0 / g.r);
	}

	if (col.g >= 0.0) {
    	col.g = pow(col.g, 1.0 / g.g);
	}

	if (col.b >= 0.0) {
    	col.b = pow(col.b, 1.0 / g.b);
	}

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


vec3 adjust_glow(vec3 col, vec4 gamma, vec4 blur, bool glow_more)
{
	float matte = clamp(blur.a, 0.0, 1.0);
	if (glow_more) {
		vec3 glow = adjust_gamma(blur.rgb, gamma);

		vec3 tmp = sqrt(glow * glow + col * col);

		col = mix(col, tmp, blur.a);
	} else {
		vec3 glow = adjust_gamma(col, gamma);
		col = mix(col, glow, matte);
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

	float i_saturation = 1.0;
	vec4 i_gamma = vec4(1.0);
	vec4 i_gain = vec4(1.0);
	vec4 i_offset = vec4(1.0);
	vec4 i_contrast = vec4(1.0);
	float i_vin_width = 1.0;
	vec4 i_vin_gamma = vec4(1.0);
	vec4 i_vin_gain = vec4(1.0);

	col = adjust_saturation(col, post_saturation * i_saturation);
    col = adjust_gamma(col, vec4(post_gamma, post_gamma_all) * i_gamma);
    col = adjust_gain(col, vec4(post_gain, post_gain_all) * i_gain);
    col = adjust_offset(col, vec4(post_offset, post_offset_all) * i_offset);
    col = adjust_contrast(col, vec4(post_contrast, post_contrast_all) * i_contrast);
	col = adjust_glow(col, vec4(glow_gamma, glow_gamma_all), blur, harsh_glow);
	col = make_vinette(col, st, vinette_width * i_vin_width, vec4(vinette_gain, vinette_gain_all) * i_vin_gain, vec4(vinette_gamma, vinette_gamma_all) * i_vin_gamma);

	gl_FragColor = vec4(col, matte);
}
