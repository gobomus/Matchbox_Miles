#version 120

uniform float adsk_result_w, adsk_result_h;
uniform float adsk_result_frameratio;
uniform sampler2D adsk_results_pass2, adsk_results_pass1, adsk_results_pass3, adsk_results_pass4, adsk_results_pass5;
uniform vec2 position;
uniform vec2 center;
uniform float radius;
uniform float angle;
uniform float scale;
uniform vec2 shear_val;
uniform float barrel;
uniform float rotation;
uniform float tilt_val;
uniform float swivel_val;
uniform float perspective;
uniform int transform_order;
uniform bool hardmatte;
uniform int result;
uniform bool input_premult;
uniform bool comp_over_front;
uniform bool repeat_texture;
uniform vec3 rot3;
uniform vec3 trans3;
uniform vec2 fly;

vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

bool isInTex( const vec2 coords )
{
        return coords.x >= 0.0 && coords.x <= 1.0 &&
                    coords.y >= 0.0 && coords.y <= 1.0;
}

vec2 translate(vec2 coords, vec2 center, vec2 position, float multiplier)
{
	position = position * vec2(multiplier);
    return coords - position;

}

vec2 barrel_distort(vec2 coords, vec2 center, float barrel, float multiplier)
{
    vec2 cc = coords - center;
    float dist = dot(cc, cc);
    coords = coords + cc * dist * barrel * multiplier;
    return coords;
}

vec2 swivel(vec2 coords, vec2 center, float swivel_val, float multiplier)
{
	float s = swivel_val * multiplier;
	float fx = fly.x * multiplier;

    mat3 m_mat = mat3(
                	1.0 + abs(s*perspective) * 2.0,	0.0, 	fx,
                	0.0,				1.0,	0.0, 
                	s,    				0.0,	1.0
                );
                
    coords -= center;

    vec3 bla = vec3(coords, 1);

    bla *= m_mat;

    coords.x = bla.x/bla.z;
    coords.y = bla.y/bla.z;

    coords += center;

    return coords;
}

vec2 tilt(vec2 coords, vec2 center, float tilt_val, float multiplier)
{
	float t = tilt_val * multiplier;
	float fy = fly.y * multiplier;

    mat3 m_mat = mat3(
                	1.0, 0.0,					0.0,
                	0.0, 1.0 + abs(t*perspective) * 2.0, 	fy,
                	0.0, t,       				1.0
                );

    coords -= center;

    vec3 bla = vec3(coords, 1); 

    bla *= m_mat;

    coords.x = bla.x/bla.z;
    coords.y = bla.y/bla.z;

    coords += center;

    return coords;
}

vec2 shear(vec2 coords, vec2 center, vec2 shear, float multiplier)
{
	vec2 s = shear * vec2(multiplier);

	mat2 shear_mat = mat2(
                        1.0, s.x, // st.x = st.x * 1.0 + st.y * shear.x
                        s.y, 1.0 // st.y = st.x * shear.y + st.y * 1.0
                    	);

	coords -= center;
    coords.x *= adsk_result_frameratio;
    coords *= shear_mat;
    coords.x /= adsk_result_frameratio;
    coords += center;

	return coords;
}

vec2 uniform_scale(vec2 coords, vec2 center, float scale, float multiplier)
{
	vec2 ss = vec2(scale*multiplier + 1.0);

    return (coords - center) / ss + center;
}

vec2 rotate(vec2 coords, vec2 center, float rotation, float multiplier)
{
	rotation *= multiplier;
    mat2 rotationMatrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

    coords -= center;
    coords.x *= adsk_result_frameratio;
    coords *= rotationMatrice;
    coords.x /= adsk_result_frameratio;
    coords += center;

    return coords;
}

vec2 twirl(vec2 coords, vec2 center, float radius, float angle, float multiplier)
{
	angle *= multiplier;
    coords -= center;

	float dist = length(coords);
	
	if (dist < radius) {
		float percent = (radius - dist) / radius;
		float theta = percent * percent * angle;
		float s = sin(theta);
		float c = cos(theta);
		coords = vec2(dot(coords, vec2(c, -s)), dot(coords, vec2(s, c)));
  	}

	coords += center;

	return coords;
}

vec2 get_coords(float multiplier) {
	vec2 coords = st;

	coords = translate(coords, center, vec2(trans3.x, trans3.y), multiplier);
	coords = tilt(coords, center, rot3.x, multiplier);
	coords = swivel(coords, center, rot3.y, multiplier);
	coords = rotate(coords, center, rot3.z, multiplier);
	coords = uniform_scale(coords, center, trans3.z, multiplier);
	coords = shear(coords, center, shear_val, multiplier);
	coords = barrel_distort(coords, center, barrel, multiplier);
	coords = twirl(coords, center, radius, angle, multiplier);

	return coords;
}

vec4 warp() {
	float warper = texture2D(adsk_results_pass5, st).r;

	vec2 coords = get_coords(warper);
	vec4 warped = vec4(0.0);

	if (repeat_texture) {
  		warped = texture2D(adsk_results_pass4, coords);

		if (result == 0) {
   			warped = texture2D(adsk_results_pass1, coords);
		}
	} else {
		if (isInTex(coords)) {
  			warped = texture2D(adsk_results_pass4, coords);
	
			if (result == 0) {
   				warped = texture2D(adsk_results_pass1, coords);
			}
		}
	}

	return warped;
}

void main()
{
    vec4 matte = texture2D(adsk_results_pass3, st);
    vec4 premult = texture2D(adsk_results_pass4, st);

	float tol = 1.0;

	vec2 around[8] = vec2[](
		vec2(-tol, tol), vec2(0.0, 1.0), vec2(tol, tol),
		vec2(-tol, 0.0), vec2(-tol, 0.0),
		vec2(-tol, -tol), vec2(0.0, -tol), vec2(-tol, -tol));

	vec4 tmp = texture2D(adsk_results_pass3, st);

	for (int i = 0; i < 8; i++) {
		if (tmp != vec4(0.0)) {
			tmp *= texture2D(adsk_results_pass3, st + around[i] / vec2( adsk_result_w, adsk_result_h));
		}
	}

	tmp = clamp(tmp, 0.0, 1.0);


	vec4 warped = vec4(0.0);
	vec4 comp = vec4(0.0);

	warped = warp();

	comp = warped;

	if (result == 1) {
    	vec4 back = texture2D(adsk_results_pass2, st);
		comp = comp + back * (1.0 - comp.a);
	} else  if (result == 2) {
		vec4 front = texture2D(adsk_results_pass1, st);
        comp = comp + front * (1.0 - comp.a);
    } else if (result == 4) {
		float warper = texture2D(adsk_results_pass5, st).r;
		vec2 coords = get_coords(warper);
		comp = vec4(coords.r, coords.g, 0.0, 0.0);
	}

	comp.a = warped.a;
	gl_FragColor = comp;
}

