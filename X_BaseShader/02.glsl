#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D Back;

uniform bool repeat_texture;

bool isInTex( const vec2 coords )
{
	return coords.x >= 0.0 && coords.x <= 1.0 &&
			coords.y >= 0.0 && coords.y <= 1.0;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 back = vec4(0.0);
	vec2 center = vec2(.5);

	if (! repeat_texture) {
		if ( isInTex(st) ) {
			back = texture2D(Back, st);
		}
	} else {
		back = texture2D(Back, st);
	}

	gl_FragColor = back;
}
