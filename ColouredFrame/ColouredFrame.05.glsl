#version 120

uniform float adsk_time, adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3, adsk_results_pass4;

uniform int process;
uniform int result;

uniform float zoom;

uniform bool show_swatch;
uniform vec2 swatch_center;
uniform float swatch_size;

uniform vec3 color;

uniform bool static_noise;

uniform vec3 cb_color1, cb_color2;
uniform float checkerboard_freq;
uniform float cb_aspect;

uniform int colorbars_type;
uniform int colorbars_p;

uniform vec2 cw_center;
uniform float cw_size;
uniform float cw_val;
uniform float cw_aspect;

vec2 texel = vec2(1.0) / res;


const vec3 lum_c = vec3(0.2125, 0.7154, 0.0721);

const vec3 white = vec3(1.0);
const vec3 black = vec3(0.0);
const vec3 red = vec3(1.0, 0.0, 0.0);
const vec3 green = vec3(0.0, 1.0, 0.0);
const vec3 blue = vec3(0.0, 0.0, 1.0);
const vec3 cyan = white - red;
const vec3 magenta = white - green;
const vec3 yellow = white - blue;

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


float mag(vec2 v) {
    // find the magnitude of a vector
    return sqrt(v.x * v.x + v.y * v.y);
}

float get_angle(vec2 center_to_point2, vec2 coords_from_center)
{
    float angle = acos(dot(center_to_point2, coords_from_center) / (mag(center_to_point2) * mag(coords_from_center)));

    return angle;
}

float draw_circle(vec2 st, vec2 center, float size, float aspect)
{
	vec2 v2 = center - (center + vec2(size));
	v2.x *= adsk_result_frameratio * aspect;
	vec2 v3 = center - st;
	v3.x *= adsk_result_frameratio * aspect;

    float circle =  1.0 - smoothstep(length(v2) - .1*.1, length(v2), length(v3));

    return circle;
}

vec3 colorwheel(vec2 st) {
	vec2 v2 = cw_center - vec2(cw_center.x - .01, cw_center.y);
	v2.x *= adsk_result_frameratio;

	vec2 v3 = cw_center - st;
	v3.x *= adsk_result_frameratio;

	vec2 v4 = cw_center - vec2(cw_center.x - cw_size * .25, cw_center.y);
	v4.x *= adsk_result_frameratio;

	float rad = distance(v4, v2);
	float d = distance(v3, v2);
	

	float angle_in_radians = get_angle(v2, v3);
	float circle = draw_circle(st, cw_center, cw_size * .25, cw_aspect);

	float angle_in_degrees = degrees(angle_in_radians);

	 if (cross(vec3(v2, 0.0), vec3(v3, 0.0)).z < 0.0) {
        angle_in_degrees = 360.0 - angle_in_degrees;
    }

	vec3 col = vec3(angle_in_degrees / 360.0);
	col.g =  d / rad;
	col.b = cw_val;

	return hsv2rgb(col) * vec3(circle);
}

vec2 scale(vec2 st, float scale_amnt, float aspect) {
	st -= vec2(.5);
	st = 2.0 * (st * scale_amnt);
	st.x *= aspect * adsk_result_frameratio;

	return st;
}

float luminance(vec3 col) {
	return clamp(dot(col, lum_c), 0.0, 1.0);
}

float random(vec2 co)
{
	float seed = adsk_time;

	if (static_noise) {
		seed = 1.0;
	}

	float a = 38.544846;
	float b = 321.468884635;
	float c = 48348.65468456;
	float dot= dot(co.xy * seed ,vec2(a,b));
	float sn= mod(dot,3.14);

	return fract(sin(sn) * c);
}

float noise(vec2 st) 
{
	vec2 p = scale(st, zoom / 100 * res.x, 1.0);
	return random(floor(p));
}

vec3 checkerboard(vec2 st, vec3 first, vec3 second)
{
	vec2 p = scale(st, checkerboard_freq * .25, cb_aspect);
	return mix(first, second, max(0.0, sign(sin(p.x)) * sign(sin(p.y))));
}

vec3 smpte_colorbars(vec2 st)
{
	vec3 col = black;
	int allon = 0;

	if (st.y < 1.0 / 4.0) {
		if (st.x < 1.0 / 6.0 * 1.0) {
			col = vec3(0.0, 0.11761, 0.47827);
		} else if (st.x < 1.0 / 6.0 * 2.0) {
			col = white;
		} else if (st.x < 1.0 / 6.0 * 3.0) {
			col = vec3(0.2666, 0.0, 0.54492);
		} else if (st.x < 1.0 / 6.0 * 4.0) {
			col = black;
		} else if (st.x < 1.0 / 6.0 * 5.0) {
			col = vec3(.03922);
		} else if (st.x < 1.0 / 6.0 * 6.0) {
			col = black;
		}
	} else {
		if (st.x < 1.0 / 7.0 * 1.0) {
			col = white;
		} else if (st.x < 1.0 / 7.0 * 2.0) {
			col = yellow;
		} else if (st.x < 1.0 / 7.0 * 3.0) {
			col = cyan;
		} else if (st.x < 1.0 / 7.0 * 4.0) {
			col = green;
		} else if (st.x < 1.0 / 7.0 * 5.0) {
			col = magenta;
		} else if (st.x < 1.0 / 7.0 * 6.0) {
			col = red;
		} else if (st.x < 1.0 / 7.0 * 7.0) {
			col = blue;
		}
	}

	if (colorbars_p == 1) {
		return col;
	} else if (allon == 0) {
		return col * vec3(.75);
	}
}

vec3 pal_colorbars(vec2 st)
{
	vec3 col = black;
	int allon = 0;

	if (st.y < 1.0 / 4.0) {
		if (st.x < 1.0 / 8.0 * 1.0) {
			col = white;
		} else if (st.x < 1.0 / 8.0 * 2.0) {
			col = vec3(.88232);
		} else if (st.x < 1.0 / 8.0 * 3.0) {
			col = vec3(.69775);
		} else if (st.x < 1.0 / 8.0 * 4.0) {
			col = vec3(.58398);
		} else if (st.x < 1.0 / 8.0 * 5.0) {
			col = vec3(.41162);
		} else if (st.x < 1.0 / 8.0 * 6.0) {
			col = vec3(.29785);
		} else if (st.x < 1.0 / 8.0 * 7.0) {
			col = vec3(.11371);
		} else if (st.x < 1.0 / 8.0 * 8.0) {
			col = black;
		}
	} else {
		if (st.x < 1.0 / 8.0 * 1.0) {
			allon = 1;
			col = white;
		} else if (st.x < 1.0 / 8.0 * 2.0) {
			col = yellow;
		} else if (st.x < 1.0 / 8.0 * 3.0) {
			col = cyan;
		} else if (st.x < 1.0 / 8.0 * 4.0) {
			col = green;
		} else if (st.x < 1.0 / 8.0 * 5.0) {
			col = magenta;
		} else if (st.x < 1.0 / 8.0 * 6.0) {
			col = red;
		} else if (st.x < 1.0 / 8.0 * 7.0) {
			col = blue;
		} else if (st.x < 1.0 / 8.0 * 8.0) {
			col = black;
		}
	}

	if (colorbars_p == 1) {
		return col;
	} else if (allon == 0) {
		return col * vec3(.75);
	}
}

vec3 colorbars(vec2 st) 
{
	if (colorbars_type == 0) {
		return smpte_colorbars(st);
	} else {
		return pal_colorbars(st);
	}	
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec3 front = texture2D(adsk_results_pass1, st).rgb;

	// Default output is solid color
	vec3 col = vec3(color);

	if (process == 0) {
		if (show_swatch) {
			float circle = draw_circle(st, swatch_center, swatch_size * .25, 1.0);
			col = mix(front, col, circle);
		}
	} else if (process == 1) {
		col = vec3(noise(st));
	} else if (process == 2) {
		col = checkerboard(st, cb_color1, cb_color2);
	} else if (process == 3) {
		col = colorbars(st);
	} else if (process == 4) {
		col = colorwheel(st);
	}

	float matte_out = luminance(col);

	gl_FragColor = vec4(col, matte_out);
}
