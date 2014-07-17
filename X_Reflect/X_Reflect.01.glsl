#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform mat4 o2v_projection_reflection;
uniform sampler2D Front, reflection_sampler;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec4 front = texture2D(Front, st);


	vec4 vClipReflection = o2v_projection_reflection * front;

	vec2 vDeviceReflection = vClipReflection.st / vClipReflection.q;
	vec2 vTextureReflection = vec2(0.5, 0.5) + 0.5 * vDeviceReflection;

	vec4 reflectionTextureColor = texture2D (reflection_sampler, vTextureReflection);

	reflectionTextureColor.a = 1.0;

	gl_FragColor = reflectionTextureColor;
}
