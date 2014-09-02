//*****************************************************************************/
//
// Filename: ZMatte.2.glsl
//
// Copyright (c) 2011 Autodesk, Inc.
// All rights reserved.
//
// This computer source code and related instructions and comments are the
// unpublished confidential and proprietary information of Autodesk, Inc.
// and are protected under applicable copyright and trade secret law.
// They may not be disclosed to, copied or used by any third party without
// the prior written consent of Autodesk, Inc.
//*****************************************************************************/
#define pi 3.141592653589793238462643383279

uniform float blur_size, adsk_result_w, adsk_result_h ;
uniform sampler2D front, adsk_results_pass1;
uniform bool softenEdges, matte_or_depth, matte_overlay;

//Parameters for the blur
//These are values that provided the best results in the widest range of cases
//These are hard set to simplify the usage of the tool
float gamma	= 0.1;
int insamples	= 16;
int samples	= 8;


//A blur that samples elliptical rings around the pixel
//'samples'	: Sets the amount of samples around the ellipse
//'insamples'	: Sets the amount of rings to sample
//'size'	: Sets the distance of the samples
//'gamma'	: Sets the gamma of weight of samples, along the distance
vec4 simple_blur (in sampler2D tex,
			int samples,
			int insamples,
			float size,
			float gamma,
			float image_width,
			float image_height ) {

	vec2 coords = gl_FragCoord.xy / vec2( image_width, image_height );
	float b_size		= size / image_width;

	//Have a minimal value for the gamma
	if (gamma < 0.01) { gamma = 0.01; };


	vec4 color = texture2D(tex, coords);
	float accum = 1.0;

	for (int i=0; i<samples; i++) {
		for (int p=0; p<insamples; p++) {
			float a = (360.0 / float(samples)) * float(i); 		//Define the angle of the sample
			//a	= a * ( pi / 180.0 ); 			        //Convert degrees to radians
			float r = b_size/float((insamples-p));		        //Set the radius/distance of the sample
			float sample_x = coords.x + r * cos(a);
			float sample_y = coords.y + r * sin(a);
			vec2 sample_coords = vec2(sample_x,sample_y);
			float dist = distance(coords,sample_coords);
			dist = pow(dist,gamma);
			color += texture2D(tex, sample_coords) * dist;
			accum += dist;
		}
	}

	color /= accum;
	return color;
}

void main()
{

	vec2 coords 		= gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec3 result		= texture2D(front, coords).rgb;


	float fg_matte;
	if ( ! softenEdges ) {
		fg_matte	= texture2D( adsk_results_pass1 , coords).a;
	} else {
		fg_matte	=  simple_blur(adsk_results_pass1, samples, insamples, blur_size, gamma, adsk_result_w, adsk_result_h ).a;
	}


	vec4 image;
	image.rgb		= result;

	image.a			= fg_matte;

	image.rgb		= matte_overlay ? image.rgb + vec3((image.a * 0.2), vec2(image.a * 0.1)) : image.rgb;


	gl_FragColor = image;
}


