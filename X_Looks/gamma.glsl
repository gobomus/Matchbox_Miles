#version 120

#define INPUT Front
#define tex(col, coords) texture2D(col, coords).rgb


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float input_gamma;
uniform float gamma;

vec3 adjust_gamma(vec3 col, float gamma)
{
	col.r = pow(col.r, gamma);
	col.g = pow(col.g, gamma);
	col.b = pow(col.b, gamma);

	return col;
}

vec3 from_rec709(vec3 col)
{
	if (col.r >= .081) {
		col.r =  pow((col.r + .099 / 1.099), 1.0 / .45);
	} else {
		col.r =  col.r / 4.5;
	}

	if (col.g >= .081) {
		col.g =  pow((col.g + .099 / 1.099), 1.0 / .45);
	} else {
		col.g =  col.g / 4.5;
	}

	if (col.b >= .081) {
		col.b =  pow((col.b + .099 / 1.099), 1.0 / .45);
	} else {
		col.b =  col.b / 4.5;
	}

	return col;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);

	col = from_rec709(col);


	gl_FragColor = vec4(col, 0.0);
}
