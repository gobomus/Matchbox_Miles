#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D adsk_results_pass6;

uniform bool scale_grid_uniform;
uniform vec2 scale_grid;
uniform float u_scale_grid;
uniform vec2 sy;

uniform vec2 scale_lines;

float rotation = 1.57;

vec2 translate(vec2 st, vec2 center, vec2 position)
{
    return (st - position) + center;

}

vec2 rotate(vec2 coords, vec2 center, float rotation)
{
    mat2 rotation_matrice = mat2( cos(-rotation), -sin(-rotation), sin(-rotation), cos(-rotation) );

    coords -= center;
    coords.x *= adsk_result_frameratio;
    coords *= rotation_matrice;
    coords.x /= adsk_result_frameratio;
    coords += center;

    return coords;
}


vec2 scale(vec2 coords, vec2 center, vec2 s)
{
	if (scale_grid_uniform) {
		s = vec2(u_scale_grid);
	}


    mat2 scale_mat = mat2(
                        vec2(1.0 + s.x, .0),
                        vec2(0.0, 1.0 + s.y)
                        );

    coords -= center;
    coords *= scale_mat;
    coords += center;

    return coords;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / res;
	vec2 coords = scale(st, vec2(.5), scale_grid);
	vec4 grid = texture2D(adsk_results_pass6, coords);


	coords = rotate(coords, vec2(.5), rotation);
	grid *= texture2D(adsk_results_pass6, coords);

	gl_FragColor = grid;
}
