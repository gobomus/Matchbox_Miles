#version 120

#define imageTex adsk_results_pass1
#define randomTex adsk_results_pass2
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform sampler2D randomTex, imageTex;

//vec2 st = gl_FragCoord.xy / res;


uniform float scale;
uniform vec2 x;
uniform float s;


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 scaledUV = st * scale;
	vec2 cell = floor(scaledUV);
	vec2 offs = scaledUV - cell;

	/*
	vec2 randomUV = cell * vec2(0.037, 0.119);
	vec4 random = texture2D(randomTex, randomUV);
	vec4 image = texture2D(imageTex, offs.xy - random.xy);
	*/

	vec2 randomUV;
	vec4 random, image;
	vec4 color = vec4(0.0);


	for (int i = -1; i <= 0; i++) {
  		for (int j = -1; j <= 0; j++) {
			vec2 cell_t = cell + vec2(i, j);
			vec2 offset_t = offs - vec2(i, j);
			randomUV = cell_t.xy * vec2(.037, .119);
			randomUV = cell_t.xy * x;

			random = texture2D(randomTex, randomUV);
			vec2 p = offset_t - random.xy;

			float angle = 2 * 3.14 * random.g;

			mat2 rot = mat2(
						cos(angle), sin(angle),
						-sin(angle), cos(angle)
			);

			//p -= vec2(.5);
			//p /= (random.r * s);
			//p *= rot;
			//p += vec2(.5);

			image = texture2D(imageTex, p);

			if (image.w > 0.0) {
				color += image;
			}
		}
	}

	

	gl_FragColor = color;
}
