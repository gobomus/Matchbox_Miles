//*****************************************************************************/
// 
// Filename: NanReplace.glsl
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

#version 130
uniform sampler2D t0;
uniform float replaceValue;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 sourceColor = texture2D(t0, coords).rgb;

   sourceColor.r = isnan( sourceColor.r ) ? replaceValue : sourceColor.r;
   sourceColor.g = isnan( sourceColor.g ) ? replaceValue : sourceColor.g;
   sourceColor.b = isnan( sourceColor.b ) ? replaceValue : sourceColor.b;

   gl_FragColor = vec4( sourceColor, 1.0 );
}
