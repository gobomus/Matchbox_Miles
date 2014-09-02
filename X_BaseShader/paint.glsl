#version 120

#define INPUT Front
//#define INPUT adsk_results_pass1
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define white vec4(1.0)
#define black vec4(0.0)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

#define DEV

uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;

uniform float adsk_time;
uniform vec2 p;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	float color;
	vec2 position = gl_FragCoord.xy;
	
	vec2 lightpos = res * p;
	
	vec2 norm = lightpos - position;
	float sdist = norm.x * norm.x + norm.y * norm.y;
	
	vec3 light_color = vec3(1.0,0.6,0.0);
	
	color = 1.0 / (sdist * 0.003);

	gl_FragColor = texture2D(INPUT,st)*0.93 + vec4(color,color,color,1.0)*vec4(light_color,1.0);

}
