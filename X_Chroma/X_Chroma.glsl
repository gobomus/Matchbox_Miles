#version 120
#define luma(col) dot(col, vec3(0.2126, 0.7152, 0.0722));


uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;

uniform float adsk_result_w, adsk_result_h;
uniform bool output_chroma;

uniform float mmix;

vec3 to_yuv(vec3 col)
{
	mat3 yuv = mat3
	(
		.2126, .7152, .0722,
		-.09991, -.33609, .436,
		.615, -.55861, -.05639
	);

	return col * yuv;
}

vec3 to_rgb(vec3 col)
{
	mat3 rgb = mat3
	(
		1.0, 0.0, 1.28033,
		1.0, -.21482, -.38059,
		1.0, 2.12798, 0.0
	);

	return col * rgb;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	// Load in the inputs
	vec3 front = texture2D(Front, st).rgb;
	vec3 back = texture2D(Back, st).rgb;
	float matte = clamp(texture2D(Matte, st), 0.0, 1.0).r;

	vec3 comp = vec3(0.0);
	front = to_yuv(front);
	vec3 backyuv = to_yuv(back);

	backyuv.gb = front.gb;
	vec3 backrgb = to_rgb(backyuv);

	float alpha = mix(matte, 0.0, mmix);

	comp = mix(back, backrgb, alpha);

	if (output_chroma) {
		comp = front;
	}

	gl_FragColor.rgb = comp;
	gl_FragColor.a = alpha;
}
