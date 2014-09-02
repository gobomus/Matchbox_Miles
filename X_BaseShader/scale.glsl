#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec3 scale;


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 center = vec2(.5);

	st -= center;

	mat3 sm = mat3(
			1.0 / scale.x, 0.0, 0.0,
			0.0, 1.0 / scale.y, 0.0,
			0.0, 0.0, 1.0 / scale.z
			);

	vec3 vst = vec3(st, 1.0);
	vst *= sm;

	st = vst.xy * vst.zz;

	st += center;


	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 0.0);
}
