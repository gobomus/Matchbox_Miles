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

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


vec2 rotate(vec2 coords, vec3 r)
{
	vec3 p = vec3(coords, 1.0);
	vec3 z = vec3(.5, .5, 1.0);
	z = vec3(res * .5, 1.0);


	float rx = r.x;
	float ry = r.y;
	float rz = r.z;

	mat3 rmx = mat3(
		1.0, 0.0	, 0.0,
		0.0, cos(rx), -sin(rx),
		0.0, sin(rx), cos(rx)
	);

	mat3 rmy = mat3(
		cos(ry),  0.0, sin(ry),
		0.0,	  1.0, 0.0,
		-sin(ry), 0.0, cos(ry)
	);

	mat3 rmz = mat3(
		cos(rz), -sin(rz), 0.0,
		sin(rz), cos(rz),  0.0,
		0.0,	 0.0,	   1.0
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
	xy = rotate(xy, rotation * vec3(.001, .001, 1.0));
	
	if (isInTex(xy / res)) {
		col = texture2D(INPUT, xy * texel);
	}

	gl_FragColor = col;
}
