#version 120

#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))

uniform float adsk_time;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

vec2 texel = vec2(1.0) / res;

uniform vec3 grain_size;
uniform float grain_size_all;
uniform vec3 grain_brightness;
uniform float grain_brightness_all;
uniform float grain_saturation;

vec3 adjust_saturation(vec3 col, float sat)
{
	vec3 intensity = vec3(luma(col));
    col = abs(mix(intensity, col, sat));
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

vec3 make_noise(vec2 st, vec4 size) {
    vec3 col = vec3(0.0);

    size.rgb *= vec3(size.a * (res.x * .5));

    vec2 cr = (size.r) * vec2(1.0, res.y/res.x);
    vec2 cg = (size.g) * vec2(1.0, res.y/res.x);
    vec2 cb = (size.b) * vec2(1.0, res.y/res.x);

    float r = rand2(vec2((2.0 + adsk_time) * floor(st.x * cr.x) / cr.x, (2.0 + adsk_time) * floor(st.y * cr.y) / cr.y ));
    float g = rand2(vec2((5.0 + adsk_time) * floor(st.x * cg.x) / cg.x, (5.0 + adsk_time) * floor(st.y * cg.y) / cg.y ));
    float b = rand2(vec2((9.0 + adsk_time) * floor(st.x * cb.x) / cb.x, (9.0 + adsk_time) * floor(st.y * cb.y) / cb.y ));

    col = vec3(r,g,b);

    return col;
}

vec3 apply_grain(vec3 col, vec2 st, vec4 size, float saturation, vec4 brightness)
{
    vec3 noise = vec3(0.0);

    noise = make_noise(st, size);

    noise = adjust_saturation(noise, saturation);
    noise = adjust_gain(noise, brightness);

    noise *= noise;

    return noise;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = vec3(0.0);

	col = apply_grain(col, st, vec4(grain_size, grain_size_all), grain_saturation, vec4(grain_brightness, grain_brightness_all));
	col = clamp(col, 0.0, 1.0);

	gl_FragColor = vec4(col, luma(col));
}
