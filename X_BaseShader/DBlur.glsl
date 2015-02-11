#version 120

// Change the folling 4 lines to suite
#define INPUT Front
#define STRENGTH Strength
#define AMT blur_amount
//#define VERTICAL 
#define STRENGTH_CHANNEL 

#define X adsk_result_w
#define Y adsk_result_h
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define PI 3.141592653589793238462643383279502884197969


#ifdef VERTICAL
    uniform float v_bias;
    float bias = v_bias;
    const vec2 dir = vec2(0.0, 1.0);
#else
    uniform float h_bias;
    float bias = 1.0;
    const vec2 dir = vec2(-1.0, 0.0);
#endif

uniform sampler2D INPUT;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D STRENGTH;
#endif

uniform float AMT;
uniform float X, Y, ratio;
vec2 res = vec2(X, Y);
vec2 texel  = vec2(1.0) / res;

uniform float angle;

vec2 rotate(vec2 coords, float rz)
{
	float r = radians(rz);
	mat2 rmz = mat2(
        cos(r), -sin(r),
        sin(r), cos(r)  
	);

	return coords * rmz;
}

vec4 gblur()
{
	//The blur function is based heavily off of lewis@lewissaunders.com Ls_Ash shader

	float f = 1.0 *ratio;
	vec2 xy = gl_FragCoord.xy;
  	vec2 px = vec2(1.0) / res;

	float strength = 1.0;

	//Optional texture used to weight amount of blur
	#ifdef STRENGTH_CHANNEL
		strength = texture2D(STRENGTH, gl_FragCoord.xy / res).r;
	#endif

	float sigma = AMT * bias * strength + .001;
   
	int support = int(sigma * 3.0);

	vec3 g;
	g.x = 1.0 / (sqrt(2.0 * PI) * sigma);
	g.y = exp(-0.5 / (sigma * sigma));
	g.z = g.y * g.y;

	vec4 a = g.x * texture2D(INPUT, xy * px);
	float energy = g.x;
	g.xy *= g.yz;

	for(float i = 1; i <= support; i++) {
		vec2 bangle = rotate(dir, angle);
		a += g.x * texture2D(INPUT, (xy + i * bangle) * px);
		energy += 1.0 * g.x;
		g.xy *= g.yz;
	}
	a /= energy;

	return vec4(a);
}

void main(void)
{
	gl_FragColor = gblur();
}
