#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D adsk_results_pass1, adsk_results_pass3;

uniform bool repeat_texture;

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = vec3(0.0);
	float matte = 0.0;

	if (! repeat_texture) {
		if ( isInTex(st) ) {
			front = texture2D(adsk_results_pass1, st).rgb;
			matte = texture2D(adsk_results_pass3, st).r;
		}
	} else {
		front = texture2D(adsk_results_pass1, st).rgb;
		matte = texture2D(adsk_results_pass3, st).r;
	}

	vec3 premult = front * matte;

	gl_FragColor = vec4(premult, matte);
}
