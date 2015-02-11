#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform float scale;
uniform float s;

bool isInTex( const vec2 coords )
{
   	return coords.x >= 0.0 && coords.x <= 1.0 &&
          	coords.y >= 0.0 && coords.y <= 1.0;
}

float rand(vec2 co)
{
	float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec4 col = vec4(0.0);
	col = mix(col, vec4(1.0), st.x);

	

	gl_FragColor = col;
}
