//*****************************************************************************/
// 
// Filename: ColourNoise.glsl
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

uniform float adsk_result_w, adsk_result_h, adsk_time;
uniform bool animated;

float noise(vec2 coords)
{
   return fract(sin(dot(coords.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   float red =   noise( coords * (animated?adsk_time+1.0:2.0) );
   float green = noise( coords * (animated?adsk_time+2.0:3.0) );
   float blue =  noise( coords * (animated?adsk_time+3.0:4.0) );
   gl_FragColor = vec4( vec3(red, green, blue), 1.0 );
}

