//*****************************************************************************/
//
// Filename: ZComp.1.glsl
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

uniform float depth, adsk_result_w, adsk_result_h ;
uniform sampler2D t_zdepth;
uniform bool white_is_far;


//Define a matte, based on a depth in a Z-Depth pass
//The resulting image has the following information:
//IMAGE.R :	The values in the incoming Z Depth pass
//IMAGE.G :	The combination of incoming Z Depth for foreground features, and the depth for background
//IMAGE.A :	The matte for foreground features
void main()
{
	vec2 coords 		= gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec4 image	 	= texture2D(t_zdepth, coords);
	float zdepth		= image.r;
	image.a			= 0.0;

	if ( white_is_far ) {
		if ( depth > zdepth ) {
			image.a = 1.0;
		} else {
			image.g = depth; 
		}
	} else {
		if ( depth < zdepth ) {
			image.a = 1.0;
		} else {
			image.g = depth;
		}
	}

	gl_FragColor = image;
}


