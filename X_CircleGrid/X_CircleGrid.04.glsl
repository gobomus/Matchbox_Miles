#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass1, adsk_results_pass3;

uniform float softness;
uniform float aspect;
uniform int grid_type;
vec2 center = vec2(.5);

uniform vec2 shape_offset;

uniform float circle_size;

uniform float triangle_size;
bool shaded_triangle = false;

vec2 unalign(vec2 st) {
    st.x /= adsk_result_frameratio;
	st += center;

	return st;
}

vec2 align(vec2 st) {
	st -= center;
    st.x *= adsk_result_frameratio;

	return st;
}

float draw_triangle(vec2 st)
{
    vec2 t = vec2(.5, triangle_size * 2.0);
	vec2 l = t;
    vec2 r;

	float s = softness * .001;

	float a1 = radians(120.0);

	l = align(t);
   	mat2 rotationMatrice = mat2( cos(a1), -sin(a1), sin(a1), cos(a1) );
	l *= rotationMatrice;
	l.x *= aspect;
	l = unalign(l);

	t.y -= l.y;
	l.y = 0.0;

	r.x = 1.0 - l.x;
	r.y = l.y;

	t += shape_offset;
	l += shape_offset;
	r += shape_offset;

    vec2 v0 = t - l;
    vec2 v1 = r - l;
    vec2 v2 = st - l;

    float dot00 = dot(v0, v0);
    float dot01 = dot(v0, v1);
    float dot02 = dot(v0, v2);
    float dot11 = dot(v1, v1);
    float dot12 = dot(v1, v2);

    float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    float col = 0.0;

	/*
    if (u >= 0 && v >= 0 && u + v <= 1) {
		if (v < .01) {
            col = smoothstep(0.0, .01, v);
        } else if (u + v > .98) {
            col = smoothstep(1.0, .99, u+v);
        } else {
            col = 1.0;
        }


    }
	*/

	if (shaded_triangle) {
		if (u < .1) {
			col = .75;
		} else if (v < .1) {
			col = .5;
		} else if (u+v < 1.1) {
			col = v;
		}
	} else {
		if (st.y <= t.y && st.x >= l.x && st.x < r.x) {

    		if (u >= 0.0 && v >= 0.0 && u + v <= 1.0) { // current uvs fall in between triangle's edges
				col = 1.0;
			}

			if (u > 0.0 && u < s) { //bottom side
				col *= smoothstep(0.0, s, u);
	
			} 
			
			if (v < s && v > 0.0) { // left side
				col *= smoothstep(0.0, s, v);
	
			} 
			
			if (u+v < 1.0 && u+v > 1.0 - s) {
				col *= 1.0 - smoothstep(1.0 - s, 1.0, u+v); // right size
			}
		}

		col = clamp(col, 0.0, 1.0);
	}

	return col;
}

float draw_circle(vec2 st)
{
	st = align(st);
	st.x /= aspect;
	st += center;

	st += shape_offset;

	vec2 from_center = vec2(center.x, center.y + circle_size);
    float circle =  1.0 - smoothstep(
								distance(center, from_center) - softness * .001,
								distance(center, from_center),
								distance(center, st)
							);

    return circle;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec4 white = vec4(1.0);
	vec4 black = vec4(0.0);

	float shape = draw_circle(st);
	grid_type == 1 ? shape = draw_triangle(st) : shape;

	vec4 col = mix(black, white, shape);
	col.a = shape;

	gl_FragColor = col;
}
