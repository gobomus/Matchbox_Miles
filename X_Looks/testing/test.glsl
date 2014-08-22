#version 120

#define INPUT Front
#define tex(col, coords) texture2D(col, coords).rgb


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float gain, gamma;

void main()
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);

	const mat3 to_xyz = mat3(
		0.4124564, 0.3575761, 0.1804375,
		0.2126729, 0.7151522, 0.0721750,
		0.0193339, 0.1191920, 0.9503041
	);


	const mat3 to_rgb = mat3(
		3.2404542,-1.5371385,-0.4985314,
		-0.9692660, 1.8760108, 0.0415560,
		0.0556434,-0.2040259, 1.0572252
	);


	//col *= to_xyz;
	col = pow(col, vec3(2.2));
	//col *= to_rgb;

	col *= gain;
	col = pow(col, vec3(1.0 / gamma));

	//col *= to_xyz;
	col = pow(col, vec3(1.0/2.2));
	//col *= to_rgb;

	gl_FragColor = vec4(col, 0.0);
}


