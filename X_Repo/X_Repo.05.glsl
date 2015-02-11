#version 120

#define b adsk_results_pass2
#define f1 adsk_results_pass3
#define f2 adsk_results_pass4
#define ratio adsk_result_frameratio
#define luma(col) dot(col, vec3(0.2125, 0.7154, 0.0721))
#define lumalin(col) dot(col, vec3(0.3086, 0.6094, 0.0820))

uniform sampler2D f1, b, f2, m;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel  = vec2(1.0) / res;
vec2 center = vec2(.5);

uniform vec3 translate1;
uniform vec2 scale1;
uniform float rotate1;
uniform bool front_premult;
uniform float mix1;

uniform vec3 translate2;
uniform vec2 scale2;
uniform float rotate2;
uniform bool front2_premult;
uniform float mix2;

uniform bool swap;
uniform int blend_mode1;
uniform int blend_mode2;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 rotate(vec2 coords, float r)
{
	r = radians(r);

	mat2 rm = mat2(
		cos(r), -sin(r),
		sin(r), cos(r)
	);

	coords -= center;
    coords.x *= ratio;
    coords *= rm;
    coords.x /= ratio;
    coords += center;
	
	return coords;
}

vec2 scale(vec2 coords, vec2 s)
{
	s /= 100.0;

	coords -= center;
	coords.x *= ratio;
	coords /= s;
	coords.x /= ratio;
	coords += center;

	return coords;
}

vec2 translate(vec2 coords, vec3 t)
{
    vec4 p = vec4(coords, 1.0, 1.0);

    p.xy -= center;

    mat4 tmx = mat4(
        1.0, 0.0, 0.0, -t.x / res.x,
        0.0, 1.0, 0.0, -t.y / res.y,
        0.0, 0.0, 1.0, t.z / max(res.x, res.y),
        0.0, 0.0, 0.0, 1.0
    );

    p *= tmx;
    p /= p.z;

    p.xy += center;

    coords = p.xy;

    return coords;
}

//http://www.ananasmurska.org/tools/PhotoshopMathFP.glsl
#define overlay(base, blend)    (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define softlight(base, blend)  ((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define hypot(base, blend) (sqrt(base * base + blend * blend))
#define screen(base, blend)         (1.0 - ((1.0 - base) * (1.0 - blend)))
#define exclusion(base, blend) 	(base + blend - 2.0 * base * blend)
#define diff(base, blend) 	abs(base - blend)

vec4 cimg(vec4 f, vec4 b, float a, bool p, int blend_mode)
{
	vec4 comp = vec4(0.0);

	if (p) {
		f /= f.a;
		f = clamp(f, 0.0, 1.0);
	}

	if (blend_mode == 0) {
		comp = f;
	} else if (blend_mode == 1) {
		// Average
		comp = (f + b) * .5;
	} else if (blend_mode == 2) {
		// Min
		comp = min(f, b);
	} else if (blend_mode == 3) {
		// Multiply
		comp = f * b;
	} else if (blend_mode == 4) {
		// Max
		comp = max(f, b);
	} else if (blend_mode == 5) {
		// Screen
		comp = screen(b, f);
	} else if (blend_mode == 6) {
		comp = hypot(b, f);
	} else if (blend_mode == 7) {
		// Add
		comp = b + f;
	} else if (blend_mode == 8) {
		// Softlight
		comp.r = softlight(b.r, f.r);
		comp.g = softlight(b.g, f.g);
		comp.z = softlight(b.z, f.z);
	} else if (blend_mode == 9) {
		// Overlay
		comp.r = overlay(b.r, f.r);
		comp.g = overlay(b.g, f.g);
		comp.z = overlay(b.z, f.z);
	} else if (blend_mode == 10) {
		// Difference
		comp = diff(b, f);
	} else if (blend_mode == 11) {
		// Exclusion
		comp = exclusion(b, f);
	} else if (blend_mode == 12) {
		// Subtract
		comp = f - b;
	}

	comp = mix(b, comp, a);
	
	return comp;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 f1c = st;
	vec2 f2c = st;

	f1c = translate(f1c, translate1);
	f1c = rotate(f1c, rotate1);
	f1c = scale(f1c, scale1);

	f2c = translate(f2c, translate2);
	f2c = rotate(f2c, rotate2);
	f2c = scale(f2c, scale2);

	vec4 back = vec4(0.0);
	vec4 col = vec4(0.0);
	vec4 front = vec4(0.0);
	vec4 front2 = vec4(0.0);

	if (isInTex(f1c)) {
		front = texture2D(f1, f1c);
	}

	if (isInTex(f2c)) {
		front2 = texture2D(f2, f2c);
	}

	vec4 fr1 = front;
	vec4 fr2 = front2;
	float m1 = mix1;
	float m2 = mix2;
	int b1 = blend_mode1;
	int b2 = blend_mode2;
	bool p1 = front_premult;
	bool p2 = front2_premult;

	if (swap) {
		fr1 = front2;
		fr2 = front;
		m1 = mix2;
		m2 = mix1;
		b1 = blend_mode2;
		b2 = blend_mode1;
		p1 = front2_premult;
		p2 = front_premult;
	}

	back = texture2D(b, st);

	col = cimg(fr1, back, fr1.a * m1, p1, b1);
	col = cimg(fr2, col, fr2.a * m2, p2, b2);

	col.a = max(front.a, front2.a);

	gl_FragColor = col;
}
