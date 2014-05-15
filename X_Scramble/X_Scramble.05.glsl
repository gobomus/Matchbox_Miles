#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;

uniform sampler2D adsk_result_pass1;
uniform sampler2D Front;
uniform float adsk_time;

uniform float amount;
uniform float scale;

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 * adsk_time * .5);
}

vec2 uniform_scale(vec2 coords, vec2 center, float scale)
{
    vec2 ss = vec2(scale / vec2(100.0));

    return (coords - center) / ss + center;
}

vec2[8] build_matrix()
{
	vec2 tlft = vec2(-1.0, 1.0);
	vec2 tcnt = vec2(0.0, 1.0);
	vec2 trt = vec2(1.0, 1.0);
	vec2 mlft = vec2(-1.0, 0.0);
	vec2 mrt = vec2(1.0, 0.0);
	vec2 blft = vec2(-1.0, -1.0);
	vec2 bcnt = vec2(0.0, -1.0);
	vec2 brt = vec2(1.0, -1.0);
		
	vec2 around[8] = vec2[](
		tlft,
		tcnt,
		trt,
		mlft,
		mrt,
		blft,
		bcnt,
		brt
	);

	return around;
}
	
void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 front = vec4(0.0);

	vec2[8] around = build_matrix();
	vec2 random = vec2(rand(st.xx), rand(st.yy));
	random *= amount;
	vec2 v1 = st - random;
	
	for (int i = 0; i < 8; i++) {
		vec2 n = around[i]*amount;
		n *= around[i]*amount/st;
		st = uniform_scale(n, vec2(.5), scale);
		front += texture2D(adsk_result_pass1, st);
	}

	front /= 8.0;


	gl_FragColor = front;
}
