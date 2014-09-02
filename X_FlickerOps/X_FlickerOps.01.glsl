#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D LockFrame, Front;
uniform float lod;
uniform int operation;
uniform bool match_chroma;

#extension GL_ARB_shader_texture_lod : enable

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec4 lum = vec4(0.2125, 0.7154, 0.0721, 0.0);

	vec4 front = vec4(0.0);
	vec4 front_avg = texture2DLod(Front, st, lod);
	vec4 lock_frame = texture2DLod(LockFrame, st, lod);

	vec4 new_gain = vec4(0.0);

	if (operation == 1) {
		new_gain = front_avg / lock_frame;
		front = texture2D(LockFrame, st);
	} else {
		new_gain = lock_frame / front_avg;
		front = texture2D(Front, st);
	}

	float gdif = dot(new_gain, lum);

	if (match_chroma) {
		front *= new_gain;
	} else {
		front *= gdif;
	}

	gl_FragColor = vec4(front.rgb, gdif);
}
