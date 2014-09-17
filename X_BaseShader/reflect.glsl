//#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform vec2 m, rn, s;
uniform float o;
uniform float a;
uniform float rs;
uniform vec3 rot, nrot;
uniform vec3 cam;
uniform vec3 axis;
//uniform vec3 dir, line;
uniform float angle;
uniform float near, far;
uniform float fov;
uniform float width;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


vec2 rotate(vec2 coords, vec3 dir)
{
	coords -= .5;
	coords.x *= ratio;

	vec4 t = vec4(coords, 1.0, 1.0);

	float u = dir.x;
	float v = dir.y;
	float w = dir.z;

	float u2 = u * u;
	float v2 = v * v;
	float w2 = w * w;
	
	float L = u2 + v2 + w2;

	/*
	float a = line.x;
	float b = line.y;
	float c = line.z;
	*/

	float a = 0.0;
	float b = 0.0;
	float c = 1.0;


	mat4 ra = mat4(
				(u2 + (v2 + w2) * cos(angle))/L, (u * v * (1.0 - cos(angle)) - w * sqrt(L) * sin(angle)) / L, (u * w * (1.0 - cos(angle)) + v * sqrt(L) * sin(angle)) / L,
																			((a * (v2 + w2) - u * (b * v + c * w)) * (1.0 - cos(angle)) + (b * w - c * v) * sqrt(L) * sin(angle)) / L,																		

				(u * v * (1.0 - cos(angle)) + w * sqrt(L) * sin(angle)) / L, (v2 + (u2 + w2) * cos(angle)) / L, (v * w * (1.0 - cos(angle)) - u * sqrt(L) * sin(angle)) / L,
																			((b * (u2 + w2) - v * (a * u + c * w)) * (1.0 - cos(angle)) + (c * u - a * w) * sqrt(L) * sin(angle)) / L,

				(u * w * (1.0 - cos(angle)) - v * sqrt(L) * sin(angle)) / L, (v * w * (1.0 -cos(angle)) + u * sqrt(L) * sin(angle)) / L, (w2 + (u2 + v2) * cos(angle)) / L,
																			((c * (u2 + v2) - w * (a * u + b * v)) * (1.0 -cos(angle)) + (a *v - b * u) * sqrt(L) * sin(angle)) / L,

				0, 0, 0, 1
	);


	float d = 1.0 / tan(fov/2.0);

				//d/(width * cos(angle)), 0.0, 0.0, 0.0,
	mat4 pa = mat4(
				d/width, 0.0, 0.0, 0.0,
				0.0, d, 0.0, 0.0,
				0.0, 0.0, (near + far) / (near - far), (2.0 * near * far) / (near - far),	
				0.0, 0.0, -1, 0.0
	);

	t *= pa;
	t.xy /= t.z;

	t *= ra;
	t.xy /= t.z;

	coords = t.xy;

	coords.x /= ratio;
	coords += .5;
	

	return coords;
}



void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = vec3(0.0);

	//st /= s;
	//st += m;
	st = rotate(st);

	if (isInTex(st)) {
		col = texture2D(INPUT, st).rgb;
	}

	vec2 n = rn;
	normalize(n);


	vec2 r = reflect(st, n);

	if (isInTex(r)) {
		vec3 ref = texture2D(INPUT, r).rgb;
		col = mix(col, ref, rs);
	}

	gl_FragColor = vec4(col, 0.0);
}
