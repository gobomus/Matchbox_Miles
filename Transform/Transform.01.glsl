#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define white vec4(1.0)
#define black vec4(0.0)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

//#define DEV

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform bool repeat_texture;
uniform bool uniform_scale;
uniform vec3 rotation;
uniform vec3 perspective;
uniform vec3 position;

#ifdef DEV
	vec2 center = vec2(.5);
	vec3 scale = vec3(100, 100, 100);
#else
	uniform vec2 center;
	uniform vec3 scale;
#endif

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}

bool check_repeat(vec2 CP)
{
	if (repeat_texture) {
		return true;
	} else if (isInTex(CP)) {
		return true;
	} else {
		return false;
	}
}

vec2 align(vec2 AP, int op)
{
	vec2 C = center;
	if (op == 0) {
		AP -= C;
		AP.x *= ratio;
	} else {
		AP.x /= ratio;
		AP += C;
	}

	return AP;
}

vec2 translate_point(vec2 TP)
{
	vec3 POSITION = position;
	POSITION.xy /= res;
	POSITION.x *= ratio;

	TP = align(TP, 0);
	vec3 VTP = vec3(TP, 1.0);

	mat3 tp =  mat3(
                  	1.0, 0.0, -POSITION.x,
                   	0.0, 1.0, -POSITION.y,
                   	0.0, 0.0, 1.0 + POSITION.z
                   );

	VTP *= tp;

	TP = VTP.xy;

	TP /= VTP.z;

	TP = align(TP, 1);

	return TP;
}

vec2 scale_point(vec2 SP)
{
	vec3 SCALE = scale / vec3(100);
	
	SP = align(SP, 0);
	SP /= vec2(SCALE.z) * vec2(SCALE.x, SCALE.y);
	SP = align(SP, 1);

	return SP;
}

vec2 rotate_point(vec2 RP)
{
	float ROTZ = radians(rotation.z);
	float ROTY = radians(rotation.y);
	float ROTX = radians(rotation.x);

	RP = align(RP, 0);
	vec3 VRP = vec3(RP, 1.0);

    mat3 rx = mat3(
                    1.0, 0.0,                      		0.0,
                    0.0, 1.0 + abs(ROTX * .5) * 2.0,   	0.0,
                    0.0, ROTX,                         	1.0
                    );

	VRP *= rx;

    mat3 ry = mat3(
                    1.0 + abs(ROTY * .5) * 2.0, 0.0, 0.0,
                    0.0,                  		1.0, 0.0,
                    ROTY,                     	0.0, 1.0
                    );

    VRP *= ry;

    mat3 rz = mat3(
          			cos(-ROTZ), -sin(-ROTZ),  	0.0,
                  	sin(-ROTZ), cos(-ROTZ),  	0.0,
                    0.0,     	0.0,   			1.0
                  );

	VRP *= rz;

	RP = VRP.xy;

	RP /= VRP.z;

	RP = align(RP, 1);

	return RP;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 coords = st;
	vec3 col = vec3(0.0);

	coords = translate_point(coords);
	coords = scale_point(coords);
	coords = rotate_point(coords);

	if (check_repeat(coords)) {
		col = tex(INPUT, coords);
	}

	gl_FragColor = vec4(col, 0.0);
}
