uniform float size, blur_amount, adsk_result_w, adsk_result_h;
uniform int gridSize;
uniform sampler2D front;
uniform bool bw, squares, useLuma, useImage;
uniform vec3 bg_color;


float luminance(vec3 c)
{
	return dot( c, vec3(0.3, 0.59, 0.11) );
}

bool isInElipse (vec2 c, vec2 currentPos, float a, float b) {
	float x = pow(currentPos.x - c.x,2.0);
	float y = pow(currentPos.y - c.y,2.0);
	float aa = a*a;
	float bb = b*b;
	if ( (x/aa + y/bb) < 1.0 ) {
		return true;
	} else {
		return false;
	}
}	

vec4 makeColouredDots (in sampler2D tex,
		int grid_size,
		float dot_size,
		bool use_luma,
		vec4 bg,
		float image_width,
		float image_height
		) {

	vec4 color;

	vec2 coords     = gl_FragCoord.xy / vec2(image_width, image_height );
	vec2 res	= vec2(image_width, image_height) / vec2(grid_size);
	ivec2 pixel	= ivec2(floor(coords * res));
	vec2 halfStep   = 1.0/(res)/2.0;
	vec2 center	= vec2( (vec2(pixel)/res) + halfStep );

	float dist	= distance(center,coords);
	float lum	= luminance(texture2D(tex, center).rgb) * dot_size;
	float scale	= useLuma ? lum : 1.0 * dot_size;
	scale		= scale > dot_size ? dot_size : scale;
 
	if ( isInElipse(center, coords, halfStep.x * scale, halfStep.y * scale) ) {
		color           = texture2D(front, center);
	} else {
		color           = bg;
	}

	return color;
}

vec4 makeColouredSquares (in sampler2D tex,
	int grid_size,
	float square_size,
	bool use_luma,
	vec4 bg,
	float image_width,
	float image_height
	) {

	vec4 color;
	vec2 coords     = gl_FragCoord.xy / vec2(image_width, image_height );
	vec2 res        = vec2(image_width, image_height) / vec2(grid_size);
	ivec2 pixel     = ivec2(floor(coords * res));
	vec2 halfStep   = 1.0/(res)/2.0;
	vec2 center     = vec2( (vec2(pixel)/res) + halfStep );
	
	float lum       = luminance(texture2D(tex, center).rgb) * square_size;
	lum     	= useLuma ? lum : 1.0 * square_size;

	if (distance(coords.x, center.x) < halfStep.x * lum && distance(coords.y, center.y) < halfStep.y * lum) {
		color           = texture2D(front, center);
	} else {
		color           = bg;
	}

	return color;
}


void main()
{
	vec4 image;
	vec4 bg		= vec4(bg_color, 0.0);
	float a_size	= size * ((float(gridSize) - blur_amount) / float(gridSize));
	if (squares) {
		image		= makeColouredSquares (front, gridSize, size, useLuma, bg, adsk_result_w, adsk_result_h);
		image.a		= makeColouredSquares (front, gridSize, a_size, useLuma, bg, adsk_result_w, adsk_result_h).a;
	} else {
		image		= makeColouredDots (front, gridSize, size, useLuma, bg, adsk_result_w, adsk_result_h);
		image.a		= makeColouredDots (front, gridSize, a_size, useLuma, bg, adsk_result_w, adsk_result_h).a;
	}

	gl_FragColor = image;
}

