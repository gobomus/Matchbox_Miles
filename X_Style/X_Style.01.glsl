#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;
uniform vec4 contrast, gain, gamma, lift;
uniform float pre_saturation;
uniform float post_saturation;
uniform int colorspace;
uniform int look;




#define luma(col) dot(col, vec3(0.3086, 0.6094, 0.0820))




vec3 from_sRGB(vec3 col)
{
    if (col.r >= 0.0) {
        col.r = pow((col.r +.055)/ 1.055, 2.4);
    }

    if (col.g >= 0.0) {
        col.g = pow((col.g +.055)/ 1.055, 2.4);
    }

    if (col.b >= 0.0) {
        col.b = pow((col.b +.055)/ 1.055, 2.4);
    }

    return col;
}

vec3 from_rec709(vec3 col)
{
    if (col.r < .081) {
        col.r /= 4.5;
    } else {
        col.r = pow((col.r +.099)/ 1.099, 1 / .45);
    }

    if (col.g < .081) {
        col.g /= 4.5;
    } else {
        col.g = pow((col.g +.099)/ 1.099, 1 / .45);
    }

    if (col.b < .081) {
        col.b /= 4.5;
    } else {
        col.b = pow((col.b +.099)/ 1.099, 1 / .45);
    }

    return col;
}

vec3 to_rec709(vec3 col)
{
    if (col.r < .018) {
        col.r *= 4.5;
    } else if (col.r >= 0.0) {
        col.r = (1.099 * pow(col.r, .45)) - .099;
    }

    if (col.g < .018) {
        col.g *= 4.5;
    } else if (col.g >= 0.0) {
        col.g = (1.099 * pow(col.g, .45)) - .099;
    }

    if (col.b < .018) {
        col.b *= 4.5;
    } else if (col.b >= 0.0) {
        col.b = (1.099 * pow(col.b, .45)) - .099;
    }


    return col;
}

vec3 to_sRGB(vec3 col)
{
    if (col.r >= 0.0) {
        col.r = (1.055 * pow(col.r, 1.0 / 2.4)) - .055;
    }

    if (col.g >= 0.0) {
        col.g = (1.055 * pow(col.g, 1.0 / 2.4)) - .055;
    }

    if (col.b >= 0.0) {
        col.b = (1.055 * pow(col.b, 1.0 / 2.4)) - .055;
    }

    return col;
}

vec3 adjust_lift(vec3 col, vec4 l)
{
	float mono = luma(col);
	float neg = 1.0 - mono;
	col = col + l.rgb * neg;
	col = col + l.a * neg;

	return col;
}

vec3 adjust_gain(vec3 col, vec4 gai)
{
    vec3 g = gai.rgb * vec3(gai.a);
    col = g.rgb * col;

    return col;
}

vec3 adjust_gamma(vec3 col, vec4 gam)
{
    vec3 g = gam.rgb * vec3(gam.a);
    if (col.r >= 0.0) {
        col.r = pow(col.r, 1.0 / g.r);
    }

    if (col.g >= 0.0) {
        col.g = pow(col.g, 1.0 / g.g);
    }

    if (col.b >= 0.0) {
        col.b = pow(col.b, 1.0 / g.b);
    }

    return col;
}

vec3 adjust_offset(vec3 col, vec4 offs)
{
    vec3 o = offs.rgb * vec3(offs.a);
    vec3 tmp = col - vec3(1.0);

    col = mix(col, tmp, 1.0 - o);

    return col;
}

vec3 adjust_contrast(vec3 col, vec4 con)
{
    vec3 c = con.rgb * vec3(con.a);
    vec3 t = (vec3(1.0) - c) / vec3(2.0);
    t = vec3(.18);

    col = (1.0 - c.rgb) * t + c.rgb * col;

    return col;
}

vec3 adjust_saturation(vec3 col, float c)
{
    float l = luma(col);
    col = (1.0 - c) * l + c * col;

    return col;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 col = texture2D(Front, st).rgb;
	vec3 one = vec3(1.0);
	float mono = luma(col);
	vec3 front = col;

	if (colorspace == 0) {
		col = from_rec709(col);
	} else if (colorspace == 1) {
		col = from_sRGB(col);
	} else if (colorspace == 2) {
		col = pow(col, vec3(2.2));
	} else if (colorspace == 3) {
		col = pow(col, vec3(1.8));
	}

	if (look == 666) {
		col = adjust_saturation(col, pre_saturation);
		col = adjust_contrast(col, contrast);
		col = adjust_lift(col, lift);
		col = adjust_gain(col, gain);
		col = adjust_gamma(col, gamma);
		col = adjust_saturation(col, post_saturation);
	}

	if (look == 0) {
		col *= vec3(mono);
		col = adjust_gain(col, vec4(one, 1.2));
		col = adjust_gamma(col, vec4(one, 1.1));
	} else if (look == 1) {
		col *= vec3(mono);
		col = adjust_saturation(col, 0.0);
		col = adjust_gain(col, vec4(1.24, .7, .25, 1.2));
		col = adjust_gamma(col, vec4(1.2, .8, .85, 1.1));
		col = adjust_saturation(col, 0.84);
	} else if (look == 2) {
		col = adjust_saturation(col, 1.5);
		col = adjust_contrast(col, vec4(1.64, 1.4, .7, 1.0));
		col = adjust_saturation(col, 0.9);
		col = pow(col, vec3(1.0/2.2));
		col = clamp(col, 0.0, 1.0);
		col *= front;
		col = pow(col, vec3(2.2));
		col = adjust_gamma(col, vec4(1.2, 1.0, 1.0, 1.38));
	} else if (look == 3) {
		float neg = 1.0 - mono;
		col = col + lift.rgb * neg;
		col = col + lift.a * neg;
	}

	if (colorspace == 0) {
		col = to_rec709(col);
	} else if (colorspace == 1) {
		col = to_sRGB(col);
	} else if (colorspace == 2) {
		col = pow(col, vec3(1.0 / 2.2));
	} else if (colorspace == 3) {
		col = pow(col, vec3(1.0 / 1.8));
	}

	col = clamp(col, 0.0, 1.0);

	gl_FragColor.rgb = col; 
}
