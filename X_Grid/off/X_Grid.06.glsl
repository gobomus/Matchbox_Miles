#version 120

uniform float adsk_result_frameratio;
uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);

//uniform bool scale_lines_uniform;
uniform vec2 scale_lines;
uniform float u_scale_lines;

uniform sampler2D adsk_results_pass5;

bool isInTex( const vec2 coords )
{
    return coords.x >= 0.0 && coords.x <= 1.0 &&
            coords.y >= 0.0 && coords.y <= 1.0;
}


vec2 scale(vec2 coords, vec2 center)
{
	vec2 s = vec2(0.0, u_scale_lines);

	/*	

	vec2 s = scale_lines;

	if (scale_lines_uniform) {
		s = vec2(u_scale_lines);
	}

	*/

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

	st = scale(st, vec2(.5));

	vec4 white = vec4(0.0);
	if (isInTex(st)) {
		white = texture2D(adsk_results_pass5, st);
	}

	gl_FragColor = white;
}
