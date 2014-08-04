#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float ring;
uniform float radius;
uniform float ring_hue;

//http://glsl.heroku.com/e#12897.0

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 makering() {
	float scale = res.y / 50.0;
	float rad = res.x*radius + .01;
	float gap = scale*.5;
	vec2 pos = gl_FragCoord.xy - res.xy*.5;
	float hue = 0.0;
	
	float d = length(pos);
	
	// Compute the distance to the closest ring
	float v = mod(d + rad/(ring*2.0), rad/ring);
	v = abs(v - rad/(ring*2.0));
	
	//v = clamp(v-gap, 0.0, 1.0);
	v = clamp(v, 0.0, 1.0);
	
	d /= rad;
	vec3 m = fract((d-1.0)*vec3(ring*-.5, -ring, ring*(hue * .01))*0.5);
	vec3 hsv = rgb2hsv(vec3(m*v));
	hsv.r += ring_hue;
	
	return vec4(hsv2rgb(hsv), 0.0);
}

void main(void)
{
	gl_FragColor = makering();
}
