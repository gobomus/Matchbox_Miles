#version 120

// Change the folling 4 lines to suite
#define INPUT adsk_results_pass8
#define tex(col, coords) texture2D(col, coords).b
#define blur_channel blur_blue
//#define VERTICAL 

#define X adsk_result_w
#define Y adsk_result_h
#define ratio adsk_result_frameratio
#define PI 3.141592653589793238462643383279502884197969


float bias = 1.0;

#ifndef VERTICAL
    int dir = 1;
#else
	int dir = 0;
#endif

uniform sampler2D INPUT;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D STRENGTH;
#endif

uniform float blur_amount, blur_channel;
uniform float X, Y, ratio;
vec2 res = vec2(X, Y);
vec2 texel  = vec2(1.0) / res;

vec4 gblur(float AMT)
{
	//The blur function is based heavily off of lewis@lewissaunders.com Ls_Ash shader

	float f = 1.0 *ratio;
	vec2 xy = gl_FragCoord.xy;
  	vec2 px = vec2(1.0) / res;

	float strength = 1.0;

	#ifdef STRENGTH_CHANNEL
		strength = texture2D(STRENGTH, gl_FragCoord.xy / res).r;
	#endif

	float sigma = AMT * bias * strength + .001;
   
	int support = int(sigma * 3.0);

	vec3 g;
	g.x = 1.0 / (sqrt(2.0 * PI) * sigma);
	g.y = exp(-0.5 / (sigma * sigma));
	g.z = g.y * g.y;

	float a = g.x * tex(INPUT, xy * px);
	float energy = g.x;
	g.xy *= g.yz;

	for(int i = 1; i <= support; i++) {
		vec2 tmp = vec2(0.0, float(i));
		if (dir == 1) {
			tmp = vec2(float(i), 0.0);
		}

		a += g.x * tex(INPUT, (xy - tmp) * px);
		a += g.x * tex(INPUT, (xy + tmp) * px);
		energy += 2.0 * g.x;
		g.xy *= g.yz;

	}
	a /= energy;

	return vec4(a);
}

void main(void)
{
    gl_FragColor = gblur(blur_channel * (blur_channel * blur_amount));
}
