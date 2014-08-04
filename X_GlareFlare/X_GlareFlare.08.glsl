#version 120
#extension GL_ARB_shader_texture_lod : enable

//This guy is pretty bloody smart
//http://john-chapman-graphics.blogspot.com/2013/02/pseudo-lens-flare.html

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = 1.0 / res;

uniform sampler2D adsk_results_pass4, adsk_results_pass7, adsk_results_pass1;

uniform int ghosts_number;
uniform float ghosts_dispersal;
uniform float halo_width;
uniform bool onlySampleCenter;
uniform float color_mix;
uniform float halo_brightness;
uniform float noise_mix;

float rand(vec2 co) {
    float seed = 10.0;
    return fract(sin(dot(co.xy, vec2(12.9898 + seed, 78.233 - seed)) + seed) * 43758.5453);
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	float noise = rand(st) * .7;

	vec2 texcoord = -st + vec2(1.0);
 
   	vec2 ghost_vector = (vec2(0.5) - texcoord) *(ghosts_dispersal * .001 + .01);
	vec3 distortion = vec3(-texel.x , 0.0, texel.x );
	vec2 direction = normalize(ghost_vector);

	vec4 rings = texture2D(adsk_results_pass7, st);
   
   	vec4 result = vec4(0.0);
   	for (int i = 0; i < ghosts_number; ++i) { 
    	vec2 offset = fract(texcoord + ghost_vector * float(i));
		float weight = 1.0;
		if (onlySampleCenter) {
		 	weight = length(vec2(0.5) - offset) / length(vec2(0.5));
		 	weight = pow(1.0 - weight, 10.0);
		}

  
		result += texture2D(adsk_results_pass4, offset) * weight;
   	}

	result = mix(result, result*noise, noise_mix);
	result = mix(result, result*rings, color_mix);

	vec2 haloVec = normalize(ghost_vector) * halo_width;
	float weight = length(vec2(0.5) - fract(texcoord + haloVec)) / length(vec2(0.5));

	weight = pow(1.0 - weight, 5.0);
	result += texture2D(adsk_results_pass4, texcoord + haloVec) * weight;
	vec4 halo = texture2D(adsk_results_pass4, texcoord + haloVec);
	halo *= halo_brightness;
	halo = clamp(halo, 0.0, 1.0);
	result += halo * weight;

	//vec4 x = texture2D(adsk_results_pass4, -st + vec2(1.0));

	gl_FragColor = vec4(result.rgb, halo.r);
}
