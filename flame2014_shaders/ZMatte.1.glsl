//*****************************************************************************/
//
// Filename: ZMatte.1.glsl
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

uniform float depth, width, adsk_result_w, adsk_result_h ;
uniform sampler2D zdepth;
uniform bool foregroundMatte;


void main()
{
	vec2 coords 		= gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
	vec4 map	 	= texture2D(zdepth, coords);
	vec4 outTex		= vec4(0.0);


	if (foregroundMatte) {
		if ( depth > map.r ) {
			outTex.a = (1.0);
		}
	} else {
		if ( distance(map.r, depth) < width) {
			outTex.a = (1.0);
		}
	}



	gl_FragColor = outTex;
}


