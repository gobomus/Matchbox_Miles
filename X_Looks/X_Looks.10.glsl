#version 120

#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

vec2 texel = vec2(1.0) / res;

uniform vec3 grain_brightness;
uniform float grain_brightness_all;
uniform float grain_saturation;

vec3 adjust_saturation(vec3 col, float c)
{
    float l = luma(col);
    col = (1.0 - c) * l + c * col;

    return col;
}

vec3 adjust_gain(vec3 col, vec4 ga)
{
    col *= ga.rgb;
    col *= ga.a;

    return col;
}

//Noise - Ivar
float rand2(vec2 co)
{
    return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 make_noise(vec2 st) {
    vec3 col = vec3(0.0);

    float r = rand2(vec2( (2.0 + adsk_time) * st.x, (2.0 + adsk_time) * st.y ) );
    float g = rand2(vec2( (5.0 + adsk_time) * st.x, (5.0 + adsk_time) * st.y ) );
    float b = rand2(vec2( (9.0 + adsk_time) * st.x, (9.0 + adsk_time) * st.y ) );

    col = vec3(r,g,b);

    return col;
}

vec3 apply_grain(vec2 st, float saturation, vec4 brightness)
{
    vec3 noise = vec3(0.0);

    noise = make_noise(st);

    noise = adjust_saturation(noise, saturation);
    noise = adjust_gain(noise, brightness);

    noise *= noise;

    return noise;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = vec3(0.0);

	col = apply_grain(st, grain_saturation, vec4(grain_brightness, grain_brightness_all));
	col = clamp(col, 0.0, 1.0);

	gl_FragColor = vec4(col, luma(col));
}
