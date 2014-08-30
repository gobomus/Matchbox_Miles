#version 120

// Change the folling 4 lines to suite
#define INPUT adsk_results_pass4
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
	const vec2 dir = vec2(0.0, 1.0);
#else
	uniform float h_bias;
	float bias = h_bias;
	const vec2 dir = vec2(1.0, 0.0);
#endif

uniform float AMT;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
uniform float blur_matte;

uniform float WIDTH, HEIGHT;
vec2 res = vec2(WIDTH, HEIGHT);
vec2 texel  = vec2(1.0) / res;

vec4 gblur()
{
	//The blur function is the work of Lewis Saunders.
	vec2 xy = gl_FragCoord.xy;

	float strength = 1.0;

	//Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = texture2D(STRENGTH, gl_FragCoord.xy / res).r;
	#endif

	float br = blur_red * AMT * bias;
	float bg = blur_green * AMT * bias;
	float bb = blur_blue * AMT * bias;
	float bm = blur_matte * AMT * bias;

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * PI) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(INPUT, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	for(float i = 1; i <= support; i++) {
		a += gx * texture2D(INPUT, (xy - i * dir) * texel);
		a += gx * texture2D(INPUT, (xy + i * dir) * texel);
		energy += 2.0 * gx;
		gx *= gy;
		gy *= gz;
	}

	a /= energy;

	return a;
}

void main(void)
{
	gl_FragColor = gblur();
}
