#version 120

#define INPUT Front
#define COLOR Color
#define tex(col, coords) texture2D(col, coords).rgb

#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))


uniform sampler2D INPUT;
uniform sampler2D COLOR;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform vec3 gainrgb;
uniform float gain;
uniform vec3 conrgb;
uniform float con;
uniform vec3 offsrgb;
uniform float offs;
uniform vec3 satrgb;
uniform float sat;

const mat3 RGB_to_XYZ = mat3(
0.4124564, 0.3575761, 0.1804375,
0.2126729, 0.7151522, 0.0721750,
0.0193339, 0.1191920, 0.9503041
);
const mat3 XYZ_to_RGB = mat3(
3.2404542,-1.5371385,-0.4985314,
-0.9692660, 1.8760108, 0.0415560,
0.0556434,-0.2040259, 1.0572252
);

vec3 adjust_gain(vec3 col, vec4 g)
{
	col = (1.0 - g.rgb) * 0.0 + g.rgb * col;
	col = (1.0 - g.a) * 0.0 + g.a * col;

	return col;
}

vec3 adjust_contrast(vec3 col, vec4 c)
{
	col = (1.0 - c.rgb) * 0.5 + c.rgb * col;
	col = (1.0 - c.a) * 0.5 + c.a * col;

	return col;
}

vec3 adjust_saturation(vec3 col, vec4 c)
{
	float l = luma(col);
	col = (1.0 - c.rgb) * l + c.rgb * col;
	col = (1.0 - c.a) * l + c.a * col;

	return col;
}




void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = texture2D(INPUT, st).rgb;
	float lum = luma(col);

	col = adjust_gain(col, vec4(gainrgb, gain));
	col = adjust_contrast(col, vec4(conrgb, con));
	col = adjust_saturation(col, vec4(satrgb, sat));

	/*
	col = (1.0 - sat) * lum + sat * col;
	col = (offs - 1.0) * 1.0 + (1.0 - (offs - 1.0)) * col;
	*/


	gl_FragColor.rgb = col;
}
