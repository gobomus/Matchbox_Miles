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

uniform sampler2D Alpha;
uniform sampler2D Grass;
uniform sampler2D Stone;
uniform sampler2D Rock;

uniform float scale;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;



   vec4 alpha   = texture2D( Alpha, st);
   vec4 tex0    = texture2D( Grass, st * scale); // Tile
   vec4 tex1    = texture2D( Rock,  st * scale); // Tile
   vec4 tex2    = texture2D( Stone, st * scale); // Tile

   tex0 *= alpha.r; // Red channel
   tex1 = mix( tex0, tex1, alpha.g ); // Green channel
   vec4 outColor = mix( tex1, tex2, alpha.b ); // Blue channel
   
   gl_FragColor = outColor;
}

