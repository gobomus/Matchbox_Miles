#version 120
#extension GL_ARB_shader_texture_lod : enable

uniform sampler2D   Front;
uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform float adsk_time;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform int lod;
uniform float threshold;
uniform float gamma;
uniform vec2 scale;
uniform int width;
uniform int brightness;

float rand(vec2 co) {
    float seed = co.x * adsk_time;
    return fract(sin(dot(co.xy, vec2(12.9898 + seed, 78.233 - seed)) + seed) * 43758.5453);
}


void main(void)
{

	vec2 st = gl_FragCoord.xy / res;
	//vec2 texel = vec2(abs(sin(adsk_time * st.x))) / res;
	vec2 texel = vec2(1.0) / res;
	vec3 front = texture2D(Front, st).rgb;
	vec3 front_mm = texture2DLod(Front, st, float(lod)).rgb;
	vec3 lc = vec3(0.2125, 0.7154, 0.0721);

	vec2 nn[8];
	nn[0] = -texel;
	nn[1] = -vec2(texel.x, 0.0);
	nn[2] = -vec2(texel.x, -texel.y);
	nn[3] = -vec2(0.0, texel.y);
	nn[4] = vec2(0.0, texel.y);
	nn[5] = vec2(texel.x, -texel.y);
	nn[6] = vec2(texel.x, 0.0);
	nn[7] = texel;

	vec4 color = vec4(0.);
	float luma = 0.0;
	float noise = 0.0;

	for (int i = 0; i < 8; i++) {
		for (int w = 1; w <= width; w++) {
			//vec3 np = texture2DLod(Front, st + nn[i] * w, lod).rgb;
			float r = texture2DLod(Front, st + nn[i] * (w + mod(w,2)), lod).r;
			float g = texture2DLod(Front, st + nn[i] * (w), lod).g;
			float b = texture2DLod(Front, st + nn[i] * (w + mod(w, 3)), lod).b;
			vec3 np = vec3(r, g, b);
   			luma = clamp(dot(np, lc), 0.0, 1.0);

			color += vec4(np, luma);
			noise += rand(st + nn[i] * w);
		}
	}

	float a = width * (8 - brightness*.1);

	color /= a;
	noise /= a;
	color *= color.a;

	float mixmatte = pow(color.a * (1.0 - threshold), gamma) * noise;


	vec3 comp = mix(front, color.rgb, mixmatte);


	gl_FragColor = vec4(comp, mixmatte);
}
