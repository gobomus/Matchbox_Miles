//*****************************************************************************/
//
// Filename: ZComp.2.glsl
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

uniform float depth, size, matte_threshold, adsk_result_w, adsk_result_h ;
uniform sampler2D t_front,t_matte,t_bg, adsk_results_pass1;
uniform bool softenEdges, matte_or_depth;

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
			float blur_size,
			float gamma,
			float image_width,
			float image_height ) {

	vec2 coords = gl_FragCoord.xy / vec2( image_width, image_height );
	blur_size		= blur_size / image_width;

	//Have a minimal value for the gamma
	if (gamma < 0.01) { gamma = 0.01; };


	vec4 color = texture2D(tex, coords);
	float accum = 1.0;

	for (int i=0; i<samples; i++) {
		for (int p=0; p<insamples; p++) {
			float a = (360.0 / float(samples)) * float(i); 		//Define the angle of the sample
			a	= a * ( pi / 180.0 ); 			        //Convert degrees to radians
			float r = blur_size/float((insamples-p));		//Set the radius/distance of the sample
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
	vec3 front		= texture2D(t_front, coords).rgb;
	vec3 matte		= texture2D(t_matte, coords).rgb;
	vec3 bg			= texture2D(t_bg, coords).rgb;


	float fg_matte;
	if ( ! softenEdges ) {
		fg_matte	= texture2D( adsk_results_pass1 , coords).a;
	} else {
		fg_matte	=  simple_blur(adsk_results_pass1, samples, insamples, size, gamma, adsk_result_w, adsk_result_h ).a;
	}


	//The results from the first pass
	vec3 pass1_output	= texture2D(adsk_results_pass1, coords).rgb;
	//This has two useful passes:
	//pass1_output.r :	This is just the original Z Depth pass
	//pass1_output.g :	The combination of incoming Z Depth for foreground features, and the depth for background
	float orginal_depth	= pass1_output.r;
	float compound_depth	= pass1_output.g;

	//If the matte for the incoming layer is below the transparency threshold, output the original depth
	float output_depth	= matte.r <= matte_threshold ? orginal_depth : compound_depth;

	

	//Blend the images together, using the matte
	vec4 image;
	image.rgb		= (bg * vec3(1.0 - matte.r) ) + ( front * vec3(matte.r) );

	//Blend the foreground features of the scene
	image.rgb		= (image.rgb * (vec3(1.0) - vec3(fg_matte) )) + ( bg * vec3(fg_matte) );
	image.a			= matte_or_depth ?  fg_matte : output_depth;


	gl_FragColor = image;
}


