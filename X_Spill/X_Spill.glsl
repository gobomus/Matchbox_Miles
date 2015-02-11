#version 120
#define luma(col) dot(col, vec3(0.2126, 0.7152, 0.0722));


uniform sampler2D Front;
uniform sampler2D Despill;
uniform sampler2D Back;

uniform float adsk_result_w, adsk_result_h;

uniform float mmix;
uniform bool premult;
uniform float whites;
uniform bool comp;


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	// Load in the inputs
	vec3 front = texture2D(Front, st).rgb;
	vec3 despill = texture2D(Despill, st).rgb;
	//float matte = clamp(texture2D(Matte, st), 0.0, 1.0).r;

	vec3 back = vec3(0.0);
	vec3 col = vec3(0.0);

	//matte = clamp(matte, 0.0, 1.0);


	//float alpha = mix(matte, 0.0, mmix);

	vec3 diff = abs(despill - front);
	float ldiff = luma(diff);
	ldiff = mix(ldiff, 0.0, whites);
	//ldiff = clamp(ldiff, 0.0, 1.0);

	if (comp) {
		back = texture2D(Back, st).rgb;
		back *= vec3(ldiff);
		col = despill - vec3(ldiff) + back;
	} else {
		col = despill + vec3(ldiff);
	}


	gl_FragColor.rgb = col;
	gl_FragColor.a = ldiff;
}
