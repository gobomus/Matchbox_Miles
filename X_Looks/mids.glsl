#version 120

#define INPUT Front
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);


uniform float more_highs;
uniform float more_lows;

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 front = tex(INPUT, st);
	vec3 col = front;

	float highs = luma(col);
	float lows = 1.0 - highs;

	vec3 tmp  = (1.0 - smoothstep(0.5, 1.0, col));
	tmp = clamp(tmp, 0.0, 1.0);
	col = min(tmp, col);
	//col *= 2.0;
	//col = smoothstep(0.0, 1.0, col);
	col = pow(col, vec3(.5));

	col = mix(col, col + vec3(highs), more_highs);
	col = mix(col, col + vec3(lows), more_lows);

	vec3 sol = vec3(luma(col));

	gl_FragColor = vec4(front * (sol * 2.0), 1.0);
	gl_FragColor = vec4(sol, 1.0);
}
