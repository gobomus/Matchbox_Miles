//comment out to get to work on mac
//#version 130

//uncomment to get to work on mac
#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
uniform bool front_is_premultiplied;
uniform bool clamp_front, clamp_back, clamp_matte, clamp_result, clamp_unpremult;
uniform int op;
uniform float transparency;

uniform sampler2D adsk_results_pass1, adsk_results_pass2, adsk_results_pass3;

const vec4 white = vec4(1.0);
const vec4 black = vec4(0.0);

vec4 c_clamp(vec4 image) {
	return clamp(image, 0.0, 1.0);
}

vec4 c_mix(vec4 front, vec4 back, float matte) {
	float opacity = (100.0 - transparency) / 100.0;
	float alpha = matte * opacity;

	return mix(back, front, alpha);
}
	
//0
vec4 blend(vec4 front, vec4 back) {
	float opacity = (100.0 - transparency) / 100.0;
	float alpha = front.a * opacity;

	vec4 comp = front * alpha + back * (1.0 - alpha);

	return comp;
}


//  rgb<-->hsv functions by Sam Hocevar
//  http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
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

//12
vec4 color(vec4 front, vec4 back)
{
	front.rgb = rgb2hsv(front.rgb);
    front.b = rgb2hsv(back.rgb).b;

	vec4 comp = vec4(hsv2rgb(front.rgb), front.a);
	comp = c_mix(comp, back, front.a);

	return comp;
}

//11
vec4 intersect(vec4 front, vec4 back) {
	vec4 comp = front + back - 2.0 * front * back;
	comp = c_mix(comp, back, front.a);

	return comp;
}

//10
vec4 geo_merge(vec4 front, vec4 back) {
	back = c_clamp(back);
	front = c_clamp(front);
	vec4 comp = 2.0 * front * back / (front + back);
	comp = c_mix(comp, back, front.a);

	return comp;
}

//9
vec4 average(vec4 front, vec4 back) {
	vec4 comp = (front + back) / 2.0;
	comp = c_mix(comp, back, front.a);

	return comp;
}

//7
vec4 softlight(vec4 front, vec4 back) {
	bvec4 f = greaterThanEqual(front, vec4(.5));
	bvec4 b = lessThan(back, vec4(.25));

	vec4 comp = back - (1.0 - 2.0 * front) * back * (1.0 - back);
	vec4 bcomp2 = back + (2.0 * front - 1.0) * back * ((16.0 * back - 12.0) * back + 3.0);
	vec4 bcomp1 = back + (2.0 * front - 1.0) * (sqrt(back) - back);

	if (f.r) {
		comp.r = bcomp1.r;
		if (b.r) {
			comp.r = bcomp2.r;
		}
	}
	
	if (f.g) {
		comp.g = bcomp1.g;
		if (b.g) {
			comp.g = bcomp2.g;
		}
	}	

	if (f.b) {
		comp.b = bcomp1.b;
		if (b.b) {
			comp.b = bcomp2.b;
		}
	}

	comp = c_mix(comp, back, front.a);

	return comp;
}

//6
vec4 hypot(vec4 front, vec4 back) {
	vec4 comp = sqrt(front * front + back * back);
	comp = c_mix(comp, back, front.a);

	return comp;
}

//5
vec4 screen(vec4 front, vec4 back) {
	vec4 comp = max(front, back);

	bvec4 f = lessThanEqual(front, white);
	bvec4 b = lessThanEqual(back, white);

	if (f.r) {
		comp.r = front.r + back.r - front.r * back.r;
	}
	
	if (f.g) {
		comp.g = front.g + back.g - front.g* back.g;
	}
	
	if (f.b) {
		comp.b = front.b + back.b - front.b * back.b;
	}
	
	if (b.r) {
		comp.g = front.r + back.r - front.r * back.r;
	}
	
	if (b.g) {
		comp.g = front.g + back.g - front.g * back.g;
	}
	
	if (b.b) {
		comp.b = front.b + back.b- front.b * back.b;
	}

	comp.a = front.a;
	comp = blend(comp, back);

	return comp;
}

//8
vec4 overlay(vec4 front, vec4 back) {
	vec4 comp = 1.0 - 2.0 * (1.0 - front) * (1.0 - back);
	vec4 c = 1.0 - 2.0 * (1.0 - front) * (1.0 - back);

	if (back.r < .5) {
		comp.r = 2.0 * front.r * back.r;
	}

	if (back.g < .5) {
		comp.g = 2.0 * front.g * back.g;
	}

	if (back.b < .5) {
		comp.b = 2.0 * front.b * back.b;
	}

	comp = c_mix(comp, back, front.a);
	return comp;
}

//4
vec4 div(vec4 front, vec4 back) {
	vec4 comp = front / back;

	if ((1.0 - front.a) > 0.0) {
		comp = clamp(comp, 0.0, 1.0);
	}

	comp = c_mix(comp, back, front.a);

	return comp;
}

//3
vec4 mult(vec4 front, vec4 back) {
	vec4 comp = front * back;
	comp = c_mix(comp, back, front.a);
	return comp;
}

//2
vec4 sub(vec4 front, vec4 back) {
	vec4 comp = back - front;
	comp = c_mix(comp, back, front.a);
	return comp;
}

//1
vec4 add(vec4 front, vec4 back) {
	vec4 comp = c_clamp(front + back);
	comp = c_mix(comp, back, front.a);
	return comp;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	vec3 front_in = texture2D(adsk_results_pass1, st).rgb;
	vec4 back = texture2D(adsk_results_pass2, st);
	float matte = texture2D(adsk_results_pass3, st).a;

	if (clamp_front) {
		front_in = clamp(front_in, 0.0, 1.0);
	}

	if (clamp_back) {
		back = clamp(back, 0.0, 1.0);
	}

	if (clamp_matte) {
		matte = clamp(matte, 0.0, 1.0);
	}

	vec4 front = vec4(front_in, matte);

	if (front_is_premultiplied) {
		if (matte > 0.0) {
			front = vec4(front_in / vec3(matte), matte);
		}
	}

	vec4 comp = blend(front, back);

	if (op == 1) {
		comp = add(front, back);
	} else if (op == 2) {
		comp = sub(front, back);
	} else if (op == 3) {
		comp = mult(front, back);
	} else if (op == 4) {
		comp = div(front, back);
	} else if (op == 5) {
		comp = screen(front, back);
	} else if (op == 6) {
		comp = hypot(front, back);
	} else if (op == 7) {
		comp = softlight(front, back);
	} else if (op == 8) {
		comp = overlay(front, back);
	} else if (op == 9) {
		comp = average(front, back);
	} else if (op == 10) {
		comp = geo_merge(front, back);
	} else if (op == 11) {
		comp = intersect(front, back);
	} else if (op == 12) {
		comp = color(front, back);
	}

	//comment out to get to work on mac
	//comp.r = isnan( comp.r ) ? front.r : comp.r;
   	//comp.g = isnan( comp.g ) ? front.g : comp.g;
   	//comp.b = isnan( comp.b ) ? front.b : comp.b;

	comp = clamp(comp, -10000.0, 10000.0);

	if (clamp_result) {
		comp = clamp(comp, 0.0, 1.0);
	}

	gl_FragColor = vec4(comp.rgb, matte);
}
