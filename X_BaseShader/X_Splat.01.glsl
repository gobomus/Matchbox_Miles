#version 120

#define INPUT Front
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))
#define pi 3.141592653589793238462643383279502884197969

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;
vec2 center = vec2(.5);

uniform sampler2D Alpha;
uniform sampler2D Texture1;
uniform sampler2D Texture2;
uniform sampler2D Texture3;
uniform float width;
uniform float angle0;
uniform float angle1;
uniform float angle2;
uniform vec3 contrast_rgb;
uniform float contrast, contrast0, contrast1, contrast2;
uniform float saturation, saturation0, saturation1, saturation2;
uniform float scale0, scale1, scale2;
uniform float shift_hue;
uniform vec3 bgcol;

vec3 adjust_contrast(vec3 col, float con)
{
	vec3 c = vec3(con);
    vec3 t = (vec3(1.0) - c) / vec3(2.0);
    t = vec3(.5);

    col = (1.0 - c.rgb) * t + c.rgb * col;

    return col;
}

vec3 adjust_contrast_rgb(vec3 col, vec4 con)
{
    vec3 c = con.rgb * vec3(con.a);
    vec3 t = (vec3(1.0) - c) / vec3(2.0);
    t = vec3(.5);

    col = (1.0 - c.rgb) * t + c.rgb * col;

    return col;
}

vec3 adjust_saturation(vec3 col, float c)
{
    float l = luma(col);
    col = (1.0 - c) * l + c * col;

    return col;
}

vec2 rotate(vec2 coords, float rotation)
{
	rotation = radians(rotation);
    mat2 rotation_matrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

    coords -= center;
    coords.x *= adsk_result_frameratio;
    coords *= rotation_matrice;
    coords.x /= adsk_result_frameratio;
    coords += center;

    return coords;
}

vec2 uniform_scale(vec2 st, float scale)
{
    vec2 ss = vec2(scale);

    return (st - center) / ss + center;
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

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec2 a0;
	vec2 c0 = rotate(st, angle0);
	vec2 c1 = rotate(st, angle1);
	vec2 c2 = rotate(st, angle2);

	a0 = uniform_scale(st, width);
	c0 = uniform_scale(c0, scale0);
	c1 = uniform_scale(c1, scale1);
	c2 = uniform_scale(c2, scale2);

   	vec4 alpha   = texture2D( Alpha, a0);
	alpha.rgb = adjust_saturation(alpha.rgb, saturation);
	alpha.rgb = adjust_contrast_rgb(alpha.rgb, vec4(contrast_rgb, contrast));
	alpha = clamp(alpha, 0.0, 1.0);
	vec3 yiq = toyiq(alpha.rgb);
	yiq = rhue(yiq, shift_hue);
	alpha.rgb = fromyiq(yiq);
	alpha = clamp(alpha, 0.0, 1.0);

   	vec4 tex0    = texture2D(Texture1, c0);
	tex0.rgb = adjust_saturation(tex0.rgb, saturation0);
	tex0.rgb = adjust_contrast(tex0.rgb, contrast0);
	tex0 = clamp(tex0, 0.0, 1.0);

   	vec4 tex1    = texture2D(Texture2,  c1);
	tex1.rgb = adjust_saturation(tex1.rgb, saturation1);
	tex1.rgb = adjust_contrast(tex1.rgb, contrast1);
	tex1 = clamp(tex1, 0.0, 1.0);

   	vec4 tex2    = texture2D(Texture3, c2);
	tex2.rgb = adjust_saturation(tex2.rgb, saturation2);
	tex2.rgb = adjust_contrast(tex2.rgb, contrast2);
	tex2 = clamp(tex2, 0.0, 1.0);

	vec4 outColor = max(vec4(bgcol, 1.0), alpha);

	outColor = tex0 * alpha.r + outColor * (1.0 - alpha.r);
	outColor = tex1 * alpha.g + outColor * (1.0 - alpha.g);
	outColor = tex2 * alpha.b + outColor * (1.0 - alpha.b);

   	gl_FragColor = vec4(outColor.rgb, luma(alpha.rgb));
}
