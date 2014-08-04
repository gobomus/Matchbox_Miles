#version 120
#extension GL_ARB_shader_texture_lod : enable

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass3;

uniform float uScale;
uniform float uBias;
uniform float lod;

bool isInTex( const vec2 coords )
{
   return coords.x >= 0.0 && coords.x <= 1.0 &&
          coords.y >= 0.0 && coords.y <= 1.0;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	//st -= vec2(.5);
	//st /= .2;
	//st += vec2(.5);

	vec4 fResult = vec4(0.0);

	if (isInTex(st)) {
		fResult = max(vec4(0.0), texture2DLod(adsk_results_pass1, st, lod) + vec4(-.8 + uBias)) * vec4(1.5 + uScale);
	}

	gl_FragColor = fResult;
}
