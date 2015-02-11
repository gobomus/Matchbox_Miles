#version 120
#define center vec2(.5);

uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;

uniform float mmix;
uniform bool premult;

uniform vec2 ft;
uniform vec2 mt;
uniform vec2 fs;
uniform vec2 ms;
uniform float funis;
uniform float munis;

vec2 scale(vec2 coords, vec2 s)
{
	coords -= center;
	coords.x *= adsk_result_frameratio;
	coords /= s;
	coords.x /= adsk_result_frameratio;
	coords += center

	return coords;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);

	vec2 fcoords = scale(st, fs * vec2(funis));
	fcoords -= ft;

	vec2 mcoords = scale(st, ms * vec2(munis));
	mcoords -= mt;

	vec3 front = texture2D(Front, fcoords).rgb;
	vec3 back = texture2D(Back, st).rgb;
	float matte = texture2D(Matte, mcoords).r;

	float alpha = 0.0;
	vec3 comp = front;

	matte = clamp(matte, 0.0, 1.0);
	alpha = mix(matte, 0.0, mmix);

	comp = mix(back, front, alpha);


	gl_FragColor.rgb = comp;
	gl_FragColor.a = alpha;
}

