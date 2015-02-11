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

vec2 center = vec2(.5);

uniform vec3 rotation;
uniform vec3 translation;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 translate(vec2 coords, vec3 t)
{

	vec4 p = vec4(coords * texel, 1.0, 1.0);

	p.xy -= center;

	mat4 tmx = mat4(
		1.0, 0.0, 0.0, t.x,
		0.0, 1.0, 0.0, t.y,
		0.0, 0.0, 1.0, t.z,
		0.0, 0.0, 0.0, 1.0
	);

	p *= tmx;
	p /= p.z;

	p.xy += center;

	coords = p.xy / texel;

	return coords;
}


vec2 rotate(vec2 coords, vec3 r)
{
	vec4 p = vec4(coords, 1.0, 1.0);
	vec4 z = vec4(center, 1.0, 0.0);
	z = vec4(res * center, 1.0, 0.0);

	float rx = r.x;
	float ry = r.y;
	float rz = r.z;

	mat4 rmx = mat4(
		1.0, 0.0	, 0.0,		0.0,
		0.0, cos(rx), -sin(rx), 0.0,
		0.0, sin(rx), cos(rx),  0.0,
		0.0, 0.0,	  0.0,		1.0
	);

	mat4 rmy = mat4(
		cos(ry),  0.0, sin(ry), 0.0,
		0.0,	  1.0, 0.0,	  	0.0,
		-sin(ry), 0.0, cos(ry), 0.0,
		0.0, 0.0,	  0.0,		1.0
	);

	mat4 rmz = mat4(
		cos(rz), -sin(rz), 0.0, 0.0,
		sin(rz), cos(rz),  0.0, 0.0,
		0.0,	 0.0,	   1.0, 0.0,
		0.0, 0.0,	  0.0,		1.0
	);


	// Align to origin
	p -= z;

	// Apply Matrix
	p *= rmx * rmy * rmz;

	// We're done with Zed so Un-Align Zed
	p.z += z.z;

	// Perspective Divide
	p.xy /= p.z;

	// Un-Align the rest
	p.xy += z.xy;


	coords = p.xy;

	return coords;
}

void main(void)
{
	vec2 xy = gl_FragCoord.xy;
	vec2 st = gl_FragCoord.xy / res;
	vec4 col = vec4(0.0, 0.0, 0.0, 0.0);

	st = rotate(st, rotation);
	xy = rotate(xy, rotation * vec3(texel, 1.0));
	xy = translate(xy, translation);
	
	if (isInTex(xy / res)) {
		col = texture2D(INPUT, xy * texel);
		//col = texture2D(INPUT, st);
	}

	gl_FragColor = col;
}
