#version 120

uniform sampler2D Front;
uniform sampler2D Back;
uniform sampler2D Matte;

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;

vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float comp_mix;
uniform bool lock_front_and_back;
uniform bool front_is_premultiplied;

uniform vec2 front_translate, matte_translate;
uniform float front_rotation, matte_rotation;
uniform vec3 front_scale, matte_scale;

vec2 center = vec2(.5);

bool isInTex( const vec2 coords )
{
	   return coords.x >= 0.0 && coords.x <= 1.0 &&
	             coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 translate (vec2 coords, vec2 t)
{
	coords -= t / res;

	return coords;
}

vec2 rotate(vec2 coords, float r)
{
	float rotation_amount = radians(r);

	mat2 rotation_matrice = mat2(
					cos(-rotation_amount), -sin(-rotation_amount),
					sin(-rotation_amount),  cos(-rotation_amount)
	);

    coords -= center;
    coords.x *= adsk_result_frameratio;
    coords *= rotation_matrice;
    coords.x /= adsk_result_frameratio;
    coords += center;

	return coords;
}

vec2 scale(vec2 coords, vec3 s)
{
	vec2 scale_coords = vec2(s.x / 100.0, s.y / 100.0) * vec2(s.z / 100.0);

    coords -= center;
    coords.x *= adsk_result_frameratio;
    coords /= scale_coords;
    coords.x /= adsk_result_frameratio;
    coords += center;

	return coords;
}

void main()
{
	vec2 st = gl_FragCoord.xy / res;
	vec3 back = texture2D(Back, st).rgb;

	vec2 front_coords = st;

	front_coords = translate(front_coords, front_translate);
	front_coords = rotate(front_coords, front_rotation);
	front_coords = scale(front_coords, front_scale);

	vec3 front = vec3(0.0);
	
	if (isInTex(front_coords)) {
		front = texture2D(Front, front_coords).rgb;
	}

	vec2 matte_coords = st;

	if (lock_front_and_back) {
		matte_coords = front_coords;
	} else {
		matte_coords = translate(matte_coords, matte_translate);
		matte_coords = rotate(matte_coords, matte_rotation);
		matte_coords = scale(matte_coords, matte_scale);
	}

	float matte = 0.0;
	
	if (isInTex(matte_coords)) {
		matte = texture2D(Matte, matte_coords).r;
	}

	if (front_is_premultiplied) {
		float original_matte = texture2D(Matte, st).r;
		front = front / (vec3(original_matte) + .000001);
	}

	vec3 comp = vec3(0.0);

	comp = mix(back, front, matte * comp_mix);

	gl_FragColor.rgb = comp;
}
