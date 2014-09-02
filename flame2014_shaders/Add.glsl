//*****************************************************************************/
// 
// Filename: Add.glsl
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

uniform sampler2D input1, input2;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 sourceColor1 = texture2D(input1, coords).rgb;
   vec3 sourceColor2 = texture2D(input2, coords).rgb;

   gl_FragColor = vec4( sourceColor1+sourceColor2, 1.0 );
}
