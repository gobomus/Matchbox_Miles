uniform sampler2D Front;
uniform float adsk_result_w, adsk_result_h;

vec2 res = vec2(adsk_result_w, adsk_result_h);

float adsk_getLuminance ( vec3 rgb );
vec3  adskEvalDynCurves( ivec3 curve, vec3 x );


ivec3 colorCurves;


void main()
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = texture2D(Front, st).rgb;
	vec3 chan = front;

	float lum = adsk_getLuminance(front);

	vec3 newLum = adskEvalDynCurves(colorCurves.rgb, vec3(lum));

	front *= newLum;

	gl_FragColor.rgb = front;
}
