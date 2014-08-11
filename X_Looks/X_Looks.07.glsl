#version 120

#define INPUT adsk_results_pass6
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float sharpness;
uniform bool sharpen_image;
vec2 texel = vec2(1.0) / res;

// Sharpen from flame 2014 sharpen shader
vec3 sharpen(vec2 coords)
{
   	vec2 dp = texel;
   	vec3 val = tex(INPUT, coords) ;

   	if(sharpen_image) {
      	val = -texture2D(INPUT, coords - dp).rgb;
      	val += -texture2D(INPUT, coords + vec2(0.0, -dp.y)).rgb;
      	val += -texture2D(INPUT, coords + vec2(dp.x, -dp.y)).rgb;
      	val += -texture2D(INPUT, coords + vec2(-dp.x, 0)).rgb;
      	val += (8.0+sharpness)*texture2D(INPUT, coords).rgb;
      	val += -texture2D(INPUT, coords + vec2(dp.x, 0)).rgb;
      	val += -texture2D(INPUT, coords + vec2(-dp.x, dp.y)).rgb;
      	val += -texture2D(INPUT, coords + vec2(0.0, dp.y)).rgb;
      	val += -texture2D(INPUT, coords + dp).rgb;

   		val = val*(1.0/sharpness);
	}

	return val;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = sharpen(st);

	gl_FragColor = vec4(col, 0.0);
}
