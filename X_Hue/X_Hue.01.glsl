#version 120

#define INPUT Front
#define tex(col, coords) texture2D(col, coords).rgb


uniform sampler2D INPUT;
uniform float adsk_result_w, adsk_result_h, ratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

const float pi = 3.141592653589793238462643383279502884197969;

uniform float in_g;

uniform float shiftr, rfo;
uniform float shiftg, gfo;
uniform float shiftb, bfo;
uniform float shiftc, cfo;
uniform float shiftm, mfo;
uniform float shifty, yfo;

vec3 toyiq(vec3 col)
{
	mat3 ym = mat3(
        .299, .587, .114,
        .596, -.274, -.321,
        .211, -.523, .311
    );

	col *= ym;

	return col;
}

vec3 fromyiq(vec3 col)
{
	mat3 rm = mat3(
		1.0, .956, .621,
		1.0, -.272, -.647,
		1.0, -1.107, 1.705
	);

	col *= rm;

	return col;
}

vec3 rhue(vec3 col, float r)
{	
	float rmult = 180.0;
	//rmult = 1.0;

	mat3 hm = mat3(
		1.0,	0.0,	0.0,
		0.0,	cos(r * pi / rmult),	-sin(r * pi / rmult),
		0.0,	sin(r * pi / rmult),	cos(r * pi / rmult)
	);

	col *= hm;

	return col;
}

vec3 hue_ops(vec3 col, float r, float s, float v)
{
	//rgb to yiq
	mat3 ym = mat3(
		.299, .587, .114,
		.596, -.274, -.321,
		.211, -.523, .311
	);

	float rmult = 180.0;
	rmult = 1.0;

	//hue rotation
	mat3 hm = mat3(
		1.0,	0.0,	0.0,
		0.0,	cos(r * pi / rmult),	-sin(r * pi / rmult),
		0.0,	sin(r * pi / rmult),	cos(r * pi / rmult)
	);

	//saturation
	mat3 sm = mat3(
		1.0, 0.0, 0.0,
		0.0, s, 0.0,
		0.0, 0.0, s
	);

	//value
	mat3 vm = mat3(
		v, 0.0, 0.0,
		0.0, v, 0.0,
		0.0, 0.0, v
	);

	//yiq to rgb
	mat3 rm = mat3(
		1.0, .956, .621,
		1.0, -.272, -.647,
		1.0, -1.107, 1.705
	);

	col = col * ym * hm * sm * vm * rm;

	return col;
}

float get_hue(vec3 col)
{
	col = clamp(col, 0.0, 1.0);

	//compute hue from rgb
	float h = atan(sqrt(3.0) * (col.g - col.b), 2.0 * col.r - col.g - col.b);
	h = degrees(h);
	if (h < 0.0) {
		h += 360.0;
	}

	return h;
}

vec3 go(vec3 col, float g, int op)
{
	if (op == 0) {
		col = pow(col, vec3(g));
	} else {
		col = pow(col, vec3(1.0 / g));
	}

	return col;
}

vec3 shift_hue(vec3 col, float the_hue, float shift, float fo)
{
	float in_g = 1.0;

	float th = 360 - the_hue;
	float dif = -(th - 180.0);

	col = toyiq(col);
	col = rhue(col, dif);
	th += dif;
	col = fromyiq(col);

	float h = get_hue(col);
	col = toyiq(col);

	float s = 0.0;

	if (h > th) {
		s = (1.0 - smoothstep(th, th + fo, h)) * shift;
	} else {
		s = smoothstep(th - fo, th, h) * shift;
	}

	col = rhue(col, s);
	col = rhue(col, -dif);
	col = fromyiq(col);


	return col;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = tex(INPUT, st);
	col = go(col, in_g, 0);

	vec3 hues[] = vec3[](
		vec3(0.0, -shiftr, rfo),
		vec3(60.0, -shifty, yfo),
		vec3(120.0, -shiftg, gfo),
		vec3(180.0, -shiftc, cfo),
		vec3(240.0, -shiftb, bfo),
		vec3(300.0, -shiftm, mfo)
	);

	for (int i = 0; i < 6; i++) {
		col = shift_hue(col, hues[i].x, hues[i].y, hues[i].z);
	}

	col = go(col, in_g, 1);

	gl_FragColor = vec4(col, 1.0);
}


