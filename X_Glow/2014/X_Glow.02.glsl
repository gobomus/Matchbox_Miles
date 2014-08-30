#version 120

#define INPUT Back
#define tex(col, coords) texture2D(col, coords).rgb

uniform float adsk_time;
uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);


//Noise - Ivar
float rand2(vec2 co)
{
    return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

float make_noise(vec2 st) {
    vec3 col = vec3(0.0);

    float r = rand2(vec2( (2.0 + adsk_time) * st.x, (2.0 + adsk_time) * st.y ) );


    return r;
}

float apply_grain(vec2 st)
{
    float noise = make_noise(st);

    return noise;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);
	float noise = apply_grain(st);

	gl_FragColor = vec4(col, noise);
}
