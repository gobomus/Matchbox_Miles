#version 120

// Change the folling 4 lines to suite
#define INPUT Front
#define STRENGTH some_input
#define AMT blur_amount
#define VERTICAL 
//#define STRENGTH_CHANNEL 

#define WIDTH adsk_result_w
#define HEIGHT adsk_result_h
#define PI 3.141592653589793238462643383279502884197969

uniform sampler2D INPUT;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D STRENGTH;
#endif

#ifndef VERTICAL
	uniform float v_bias;
	float bias = v_bias;
	const int dir = 0;
#else
	uniform float h_bias;
	float bias = h_bias;
	const int dir = 1;
#endif

uniform float AMT;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;

uniform float WIDTH, HEIGHT;
vec2 res = vec2(WIDTH, HEIGHT);
vec2 texel  = vec2(1.0) / res;

vec3 gco(float sigma, float chan)
{
	vec3 g = vec3(0.0);

	sigma = sigma * (chan + .0000000001);
	g.x = 1.0 / (sqrt(2.0 * PI) * sigma);
	g.y = exp(-0.5 / (sigma * sigma));
   	g.z = g.y * g.y;
  	
	return g;
}

vec4 gblur()
{
	//The blur function is based heavily off of lewis@lewissaunders.com Ls_Ash shader
	bias = 1.0;

	vec2 xy = gl_FragCoord.xy;

	float strength = 1.0;

	//Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = texture2D(STRENGTH, gl_FragCoord.xy / res).r;
	#endif

	//Have to add the very small number at end or get black
	float sigma = AMT * bias * strength + .0000000001;

	vec4 a = vec4(0.0);
   
   	if (sigma > .001) {
		int support = int(sigma * 3.0);
		vec4 energy = vec4(0.0);

		vec3 rg = gco(sigma, blur_red);
		vec3 gg = gco(sigma, blur_green);
		vec3 bg = gco(sigma, blur_blue);
	
		a.r = rg.x * texture2D(INPUT, xy * texel).r;
		energy.r = rg.x;
		rg.xy *= rg.yz;
		
		a.r = gg.x * texture2D(INPUT, xy * texel).g;
		energy.g = gg.x;
		gg.xy *= gg.yz;
		
		a.r = bg.x * texture2D(INPUT, xy * texel).b;
		energy.b = bg.x;
		bg.xy *= bg.yz;

		for(int i = 1; i <= support; i++) {
			vec2 tmp = vec2(0.0, float(i));
			if (dir == 1) {
				tmp = vec2(float(i), 0.0);
			}
	
			a.r += rg.x * texture2D(INPUT, (xy - tmp) * texel).r;
			a.r += rg.x * texture2D(INPUT, (xy + tmp) * texel).r;
			energy.r += 2.0 * rg.x;
			rg.xy *= rg.yz;
	
			a.g += gg.x * texture2D(INPUT, (xy - tmp) * texel).g;
			a.g += gg.x * texture2D(INPUT, (xy + tmp) * texel).g;
			energy.g += 2.0 * gg.x;
			gg.xy *= gg.yz;
	
			a.b += bg.x * texture2D(INPUT, (xy - tmp) * texel).b;
			a.b += bg.x * texture2D(INPUT, (xy + tmp) * texel).b;
			energy.b += 2.0 * bg.x;
			bg.xy *= bg.yz;

		}

		a /= energy;
	} else {
			a = texture2D(INPUT, gl_FragCoord.xy / res);
	}

	return a;
}

void main(void)
{
	gl_FragColor = gblur();
}
