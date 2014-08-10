#version 120

#define INPUT Front
#define ratio adsk_result_frameratio
#define center vec2(.5)
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define tex(col, coords) texture2D(col, coords).rgb
#define mat(col, coords) texture2D(col, coords).r

#define white vec3(1.0)
#define black vec3(0.0)
#define gray vec4(0.5)
#define red vec3(1.0, 0.0, 0.0)
#define green vec3(0.0, 1.0, 0.0)
#define blue vec3(0.0, 0.0, 1.0)
#define cyan white - red
#define magenta white - green
#define yellow white - blue


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float red_shift;
uniform float green_shift;
uniform float blue_shift;
uniform float cyan_shift;
uniform float magenta_shift;
uniform float yellow_shift;
uniform float falloff;
uniform float saturation_clip;

uniform float red_val;
uniform float green_val;
uniform float blue_val;
uniform float cyan_val;
uniform float magenta_val;
uniform float yellow_val;


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

vec3 shift_col(vec3 source, float target, float shift_amnt, float val)
{
	vec3 col = source;
	float s = source.r;

	if (source.r > .5) {
		s = -1.0 + source.r;
		source.r = -1.0 + source.r;
	}

	source.r -= s;
	target -= s;

	float d = distance(target, abs(source.r));

	float m = 1.0 - smoothstep(0.0, .16663 * .5 + .16663, d);
	source.r += m * shift_amnt;

	source.r += s;
	col.r = source.r;
	//float vm = 1.0 - smoothstep(0.0, .2, d);
	//col.g += val * vm;

	return col;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;

	vec3 col = tex(INPUT, st);
	float lum = luma(col);

	float gap = 1.0 / 6.0;

	float rh = .0;
	float yh = .16663;
	float gh = .33325;
	float ch = .5;
	float bh = -.33325;
	float mh = -.16663;

	vec3 hsv = rgb2hsv(col);

	hsv = shift_col(hsv, rh, red_shift, red_val);
	hsv = shift_col(hsv, yh, yellow_shift, yellow_val);
	hsv = shift_col(hsv, gh, green_shift, green_val);
	hsv = shift_col(hsv, ch, cyan_shift, cyan_val);
	hsv = shift_col(hsv, bh, blue_shift, blue_val);
	hsv = shift_col(hsv, mh, magenta_shift, magenta_val);

	col = hsv2rgb(hsv);
	//col = vec3(hsv.b);

	gl_FragColor = vec4(col, 0.0);
}
