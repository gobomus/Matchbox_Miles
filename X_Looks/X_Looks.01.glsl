#version 120

#define INPUT Front
#define tex(col, coords) texture2D(col, coords).rgb


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform int i_colorspace;

vec3 from_sRGB(vec3 col)
{
	col.r = pow((col.r +.055)/ 1.055, 2.4);
	col.g = pow((col.g +.055)/ 1.055, 2.4);
	col.b = pow((col.b +.055)/ 1.055, 2.4);

	return col;
}

vec3 from_rec709(vec3 col)
{
	if (col.r < .081) {
		col.r /= 4.5;
	} else {
		col.r = pow((col.r +.099)/ 1.099, 1 / .45);
	}

	if (col.g < .081) {
		col.g /= 4.5;
	} else {
		col.g = pow((col.g +.099)/ 1.099, 1 / .45);
	}

	if (col.b < .081) {
		col.b /= 4.5;
	} else {
		col.b = pow((col.b +.099)/ 1.099, 1 / .45);
	}

	return col;
}

vec3 adjust_gamma(vec3 col, float gamma)
{
	col.r = pow(col.r, gamma);
	col.g = pow(col.g, gamma);
	col.b = pow(col.b, gamma);

	return col;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);
	if (i_colorspace == 0) {
		col = from_rec709(col);
	} else if (i_colorspace == 1) {
		col = from_sRGB(col);
	} else if (i_colorspace == 2) {
		col = adjust_gamma(col, 1.000);
	} else if (i_colorspace == 3) {
		col = adjust_gamma(col, 2.22222222222);
	} else if (i_colorspace == 4) {
		col = adjust_gamma(col, 1.8);
	}

	gl_FragColor = vec4(col, 0.0);
}
