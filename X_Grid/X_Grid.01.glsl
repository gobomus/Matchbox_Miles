#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 canvas_res = vec2(adsk_result_w, adsk_result_h);

uniform sampler2D Front;

uniform vec3 bg_color;

uniform bool grid_size_uniform;
uniform vec2 grid_size;
uniform float u_grid_size;

uniform bool line_width_uniform;
uniform vec2 line_width;
uniform float u_line_width;

uniform vec3 line_color;


vec4 grid () 
{ 
    vec2 coords = gl_FragCoord.xy / canvas_res;

	vec2 lw = line_width;

	if (line_width_uniform) {
		lw = vec2(u_line_width);
	}

	lw *= .1;

	vec2 gs = grid_size;

	if (grid_size_uniform) {
		gs = vec2(u_grid_size);
	}

	gs *= 100.0;

	vec2 ss = vec2(1.0) - lw;

    vec2 square_res = canvas_res / gs;

	coords -= vec2(.5);
    ivec2 pixel = ivec2(floor(coords * square_res));

    vec2 halfStep = 1.0 / square_res / 2.0;
    vec2 center = vec2( (vec2(pixel) / square_res) + halfStep );

    if (distance(coords.x, center.x) < halfStep.x * ss.x && 
		distance(coords.y, center.y) < halfStep.y * ss.y)
	{
        return vec4(0.0);
    } else {
        return vec4(line_color, 1.0);
    }
}


void main()
{
    vec4 image = grid();

    gl_FragColor = image;
}
