#version 120

#define INPUT adsk_results_pass1
#define STRENGTH Strength
#define AMT blur_amount
#define STRENGTH_CHANNEL 

#define WIDTH adsk_result_w
#define HEIGHT adsk_result_h
#define PI 3.141592653589793238462643383279502884197969

uniform sampler2D INPUT;

#ifdef STRENGTH_CHANNEL
	uniform sampler2D STRENGTH;
#endif

uniform float AMT;
uniform float blur_red;
uniform float blur_green;
uniform float blur_blue;
uniform float blur_matte;

uniform float WIDTH, HEIGHT;
vec2 res = vec2(WIDTH, HEIGHT);
vec2 texel  = vec2(1.0) / res;

uniform float angle;
const vec2 dir = vec2(1.0, 0.0);
const float bias = 1.0;

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
	 //The blur function is the work of Lewis Saunders.
	vec2 xy = gl_FragCoord.xy;

	float strength = 1.0;

	strength = texture2D(STRENGTH, gl_FragCoord.xy / res).r;

	float br = blur_red * AMT * bias;
	float bg = blur_green * AMT * bias;
	float bb = blur_blue * AMT * bias;
	float bm = blur_matte * AMT * bias;

	float support = max(max(max(br, bg), bb), bm) * 3.0;

	vec4 sigmas = vec4(br, bg, bb, bm) * vec4(strength);
	sigmas = max(sigmas, 0.0001);

	vec4 gx, gy, gz;
	gx = 1.0 / (sqrt(2.0 * PI) * sigmas);
	gy = exp(-0.5 / (sigmas * sigmas));
	gz = gy * gy;

	vec4 a = gx * texture2D(INPUT, xy * texel);
	vec4 energy = gx;
	gx *= gy;
	gy *= gz;

	vec2 bangle = rotate(dir, angle);

	for(float i = 1; i <= support; i++) {
        a += gx * texture2D(INPUT, (xy - i * bangle) * texel);
		energy += gx;
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
