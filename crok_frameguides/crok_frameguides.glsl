// crok_frameguide 
// Shader written by:   Kyle Obley (kyle.obley@gmail.com) & Ivar Beer

uniform sampler2D Source;

uniform float adsk_result_w, adsk_result_h, adsk_Source_frameratio, adsk_result_frameratio;
uniform float ratio, let_blend, guide_blend;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);

uniform vec3 tint_action;
uniform bool letterbox, guides;


//uniform float Thickness;
const float Thickness = 1.0;

float drawLine(vec2 p1, vec2 p2) {
	vec2 uv = gl_FragCoord.xy / resolution.xy;

	float a = abs(distance(p1, uv));
	float b = abs(distance(p2, uv));
	float c = abs(distance(p1, p2));

	if ( a >= c || b >=  c ) return 0.0;

	float p = (a + b + c) * 0.5;
	float h = 2. / c * sqrt( p * ( p - a) * ( p - b) * ( p - c));

	return mix(1.0, 0.0, smoothstep(0.5 * Thickness * 0.001  , 1.5 * Thickness * 0.001, h * adsk_result_frameratio));
}

// If percent is 0.0 it draws the center
// percent should probably get scaled by whatever the letterbox value is (haven't done that)
// could also add a length option for the center lines
float drawLine2(float percent)
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec2 co = uv * 2.0 - 1.0;

	float alpha = 0.0;

	// Adjust to taste
	float width = .001;

	float dx, dy;

	if (percent > 0.0) {
		dx = distance(abs(co.x), 1.0);
		dy = distance(abs(co.y), 1.0);

		float p = percent * .01 * 2.0;

		if (dx >= p / adsk_result_frameratio && abs(co.y) < 1.0 - p) {
			alpha = 1.0;
		}

		if (dy >= p && abs(co.x) < 1.0 - p) {
			alpha += 1.0;
		}
	
		if (dy > p + width) {
			if (dx > (p  + width) / adsk_result_frameratio) {
				alpha = 0.0;
			}
		}
	} else {
		dx = distance(abs(co.x), 0.0);
		dy = distance(abs(co.y), 0.0);

		if (dx < width * .5 / adsk_result_frameratio || dy < width * .5) {
			alpha = 1.0;
		}
	}

	return alpha;
}

void main()
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec3 source = vec3(texture2D(Source, uv).rgb);
	vec4 fin_col = vec4(source, 1.0);
	
	vec4 c_let = vec4(0.0);
	vec4 c_guide= vec4(0.0);
	float guide_alpha = 0.0;

	// Letterbox
	if ( letterbox )
	{
		float lb = ((adsk_result_w / ratio) / adsk_result_h) / 2.;
		float dist_y = length(uv.y - 0.5);
		float letterbox = smoothstep(lb, lb, dist_y);

		fin_col.rgb = mix(fin_col.rgb, vec3(0.0), letterbox * let_blend);
	}

	if ( guides )
	{
		// draw center
		guide_alpha = drawLine2(0.0);
  
		// draw action safe
		guide_alpha += drawLine2(5.0);
	
		// draw title safe
		guide_alpha += drawLine2(10.0);

		// clamp before composite
		guide_alpha = clamp(guide_alpha, 0.0, 1.0);
	
		fin_col.rgb = mix(fin_col.rgb, tint_action, guide_alpha * guide_blend);
	}
		
	gl_FragColor = fin_col;
}
