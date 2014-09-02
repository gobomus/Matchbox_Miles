//*****************************************************************************/
// 
// Filename: ColourReplace.glsl
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

uniform sampler2D frontTex;
uniform vec3 sourceColour, destColour;
uniform float adsk_result_w, adsk_result_h;
uniform float tolerance;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 frontColour = texture2D(frontTex, coords).rgb;

   frontColour = (abs( length( frontColour - sourceColour ) ) <= tolerance/100.0) ? 
                    destColour : frontColour;

   gl_FragColor = vec4( frontColour, 1.0 );
}
