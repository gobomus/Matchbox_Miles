#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec2 wave;
uniform vec2 amp;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	st.x += sin(st.y*wave.x) * amp.x;
	st.y += sin(st.x*wave.y) * amp.y;

	vec3 front = texture2D(Front, st).rgb;

	gl_FragColor = vec4(front, 0.0);
}
