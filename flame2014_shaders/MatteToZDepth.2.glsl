#define pi 3.141592653589793238462643383279


uniform float adsk_result_w, adsk_result_h;
uniform float rot, grad_offset, grad_scale, matte_depth1, matte_depth2, matte_depth3, matte_depth4, matte_depth5, matte_depth6, m_threshold; 
uniform sampler2D matte1, matte2, matte3, matte4, matte5, matte6, adsk_results_pass1;
uniform bool useGrad;


vec2 rotate ( vec2 current_coords, vec2 center, float angle) {

	vec2 new_coords;

	vec2 diff		= vec2(center) - vec2(current_coords);

	float a			= angle * ( pi / 180.0 );
	new_coords.x		= (diff.x * cos(a)) - (diff.y * sin(a));
	new_coords.y		= (diff.x * sin(a)) + (diff.y * cos(a));

	new_coords		+= center;

	return new_coords;


}

void main() {
	vec2 coords	= gl_FragCoord.xy / vec2(adsk_result_w, adsk_result_h);

	float matte_threshold	= m_threshold < 0.01 ? 0.01 : m_threshold;

	vec4 color;
	vec2 rotated_coords;
	if ( useGrad ) {
		rotated_coords	= rotate((coords*grad_scale) + vec2(grad_offset), vec2(0.5), rot);
		color		= texture2D(adsk_results_pass1, rotated_coords);
	} else { 
		color	= vec4 (1.0);
	}


	float matte1_col 	= texture2D(matte1, coords).r;
	float matte2_col 	= texture2D(matte2, coords).r;
	float matte3_col 	= texture2D(matte3, coords).r;
	float matte4_col 	= texture2D(matte4, coords).r;
	float matte5_col	= texture2D(matte5, coords).r;

	float depth1	= matte1_col < matte_threshold ? 0.0 : matte_depth1;
	float depth2	= matte2_col < matte_threshold ? 0.0 : matte_depth2;
	float depth3	= matte3_col < matte_threshold ? 0.0 : matte_depth3;
	float depth4	= matte4_col < matte_threshold ? 0.0 : matte_depth4;
	float depth5	= matte5_col < matte_threshold ? 0.0 : matte_depth5;

	color.rgb	= depth1 > 0.0 ? vec3(min(color.r, depth1)) : vec3(color.r);
	color.rgb	= depth2 > 0.0 ? vec3(min(color.r, depth2)) : vec3(color.r);
	color.rgb	= depth3 > 0.0 ? vec3(min(color.r, depth3)) : vec3(color.r);
	color.rgb	= depth4 > 0.0 ? vec3(min(color.r, depth4)) : vec3(color.r);
	color.rgb	= depth5 > 0.0 ? vec3(min(color.r, depth5)) : vec3(color.r);
	


	gl_FragColor	= color;
}
