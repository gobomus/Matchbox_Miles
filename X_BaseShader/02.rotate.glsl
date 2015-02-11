#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform vec3 rotation;
uniform float fov;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


vec2 rotate(vec2 coords, vec3 r)
{
	vec4 p = vec4(coords, 1.0, 1.0);
	vec4 z = vec4(.5, .5, 1.0, 1.0);
	//z = vec3(res * .5, 1.0);


	float rx = r.x;
	float ry = r.y;
	float rz = r.z;


	float tfov = tan(fov);
	float d = 1.0 / tfov;

	mat4 pmx = mat4(
		d , 0.0, 0.0, 0.0,
		0.0,   ratio/tfov, 0.0, 0.0,
		0.0,   0.0, (5 * .5) / (5 - .5), 1.0,
		0.0,   0.0, -2.0 * 5 * .5 / (5 - .5), 0.0
	);

	mat4 rmx = mat4(
		1.0, 0.0	, 0.0,		0.0,
		0.0, cos(rx), -sin(rx),	0.0,
		0.0, sin(rx), cos(rx),	0.0,
		0.0, 0.0,	  0.0,		1.0
	);

	mat4 rmy = mat4(
		cos(ry),  0.0, sin(ry), 0.0,
		0.0,	  1.0, 0.0,		0.0,
		-sin(ry), 0.0, cos(ry), 0.0,
		0.0,	  0.0, 0.0,		1.0
	);

	mat4 rmz = mat4(
		cos(rz), -sin(rz), 0.0, 0.0,
		sin(rz), cos(rz),  0.0, 0.0,
		0.0,	 0.0,	   1.0, 0.0,
		0.0,	  0.0, 0.0,		1.0
	);

	mat4 smx = mat4(
		ratio, 0.0, 0.0, 0.0,
		0.0,   1.0, 0.0, 0.0,
		0.0,   0.0, 1.0, 0.0,
		0.0,   0.0, 0.0, 1.0
	);

	p -= z;
	p *= pmx * rmx * rmy * rmz * smx;
	p += z;

	coords = p.xy;

	return coords;
}

void main(void)
{
	vec2 xy = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;
	vec4 col = vec4(0.0, 0.0, 0.0, 0.0);

	st = rotate(st, rotation);
	xy = rotate(xy, rotation * vec3(.001, .001, 1.0));
	
	//if (isInTex(xy / res)) {
	if (isInTex(st)) {
		col = texture2D(INPUT, xy * texel);
		col = texture2D(INPUT, st);
	}

	gl_FragColor = col;
}
