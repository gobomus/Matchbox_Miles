#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define white vec4(1.0)
#define black vec4(0.0)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

vec3 hostid = vec3(.22323, -2.123999, 01323231);
vec3 license_salt = vec3(.66839937, .9823488, -1.00238);
vec3 license = hostid * license_salt;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	hostid = vec3(.2288, 12.0, .03333);

	vec3 col = tex(INPUT, st);
	if (license / hostid != license_salt) {
		col = vec3(0.5);
	}

	gl_FragColor = vec4(col, 0.0);
}
