#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;
uniform float temp;

const vec3 lum_c = vec3(0.2125, 0.7154, 0.0721);

float luminance(vec3 col) {
    return clamp(dot(col, lum_c), 0.0, 1.0);
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;

	float t = temp + 1.0;
	front *= vec3(t, 1.0, -t + 2.0);

	front = clamp(front, 0.0, 1.0);

	gl_FragColor = vec4(front, luminance(front));
}
