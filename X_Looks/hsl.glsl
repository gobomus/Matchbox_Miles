#version 120

#define INPUT Front
#define tex(col, coords) texture2D(col, coords).rgb
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);


/*
var_R = ( R / 255 )                     //RGB from 0 to 255
var_G = ( G / 255 )
var_B = ( B / 255 )

var_Min = min( var_R, var_G, var_B )    //Min. value of RGB
var_Max = max( var_R, var_G, var_B )    //Max. value of RGB
del_Max = var_Max - var_Min             //Delta RGB value

L = ( var_Max + var_Min ) / 2

if ( del_Max == 0 )                     //This is a gray, no chroma...
{
   H = 0                                //HSL results from 0 to 1
   S = 0
}
else                                    //Chromatic data...
{
   if ( L < 0.5 ) S = del_Max / ( var_Max + var_Min )
   else           S = del_Max / ( 2 - var_Max - var_Min )

   del_R = ( ( ( var_Max - var_R ) / 6 ) + ( del_Max / 2 ) ) / del_Max
   del_G = ( ( ( var_Max - var_G ) / 6 ) + ( del_Max / 2 ) ) / del_Max
   del_B = ( ( ( var_Max - var_B ) / 6 ) + ( del_Max / 2 ) ) / del_Max

   if      ( var_R == var_Max ) H = del_B - del_G
   else if ( var_G == var_Max ) H = ( 1 / 3 ) + del_R - del_B
   else if ( var_B == var_Max ) H = ( 2 / 3 ) + del_G - del_R

   if ( H < 0 ) H += 1
   if ( H > 1 ) H -= 1
}
*/

vec3 rgb2hsl(vec3 col)
{
	col *= vec3(.9);
	//col = normalize(col);

	float col_min = min(min(col.r, col.g), col.b);
	float col_max = max(max(col.r, col.g), col.b);
	float col_delta = col_max - col_min;


	float h = 0.0;
	float s = 0.0;
	float l = (col_max + col_min) * .5;

	if (col_max != 0.0) {

		if (l < .5) {
			s = col_delta / (col_max + col_min);
		} else {
			s = col_delta / (2.0 - col_max - col_min);
		}

		float r = (((col_max - col.r) / 6) + (col_delta / 2)) / col_max;
		float g = (((col_max - col.g) / 6) + (col_delta / 2)) / col_max;
		float b = (((col_max - col.b) / 6) + (col_delta / 2)) / col_max;

		if (col.r == col_max) {
			h = b - g;
		} else if (col.g == col_max) {
			h = (1 / 3) + r - b;
		} else if (col.b == col_max) {
			h = (2 / 3) + g - r;
		}

		if (h <= 0) {
			h += 1.0;
		}

		if (h >= 1.0) {
			h -= 1.0;
		}
	}


	return vec3(h, s, l);
}
		


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);
	col = rgb2hsl(col);

	gl_FragColor = vec4(col, 0.0);
}
