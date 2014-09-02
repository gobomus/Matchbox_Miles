//*****************************************************************************/
// 
// Filename: Mux.glsl
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

uniform sampler2D t0, t1, t2, t3, t4, t5;
uniform float inputIndex;
uniform bool doBlend;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   int floorIndex = int( floor( inputIndex ) );
   int ceilIndex = int( ceil( inputIndex ) );
   
   vec3 rgb1 = vec3(0.0);
   vec3 rgb2 = vec3(0.0);
   
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   
   if ( floorIndex == 1 )
   {
      rgb1 = texture2D(t0, coords).rgb;
      rgb2 = texture2D(t1, coords).rgb;
   }
   else if ( floorIndex == 2 )
   {
      rgb1 = texture2D(t1, coords).rgb;
      rgb2 = texture2D(t2, coords).rgb;
   }
   else if ( floorIndex == 3 )
   {
      rgb1 = texture2D(t2, coords).rgb;
      rgb2 = texture2D(t3, coords).rgb;
   }
   else if ( floorIndex == 4 )
   {
      rgb1 = texture2D(t3, coords).rgb;
      rgb2 = texture2D(t4, coords).rgb;
   }
   else if ( floorIndex == 5 )
   {
      rgb1 = texture2D(t4, coords).rgb;
      rgb2 = texture2D(t5, coords).rgb;
   }
   else if ( floorIndex == 6 )
   {
      rgb1 = texture2D(t5, coords).rgb;
      rgb2 = texture2D(t5, coords).rgb;
   }
   
   gl_FragColor = vec4( doBlend ? 
                           mix( rgb1, rgb2, inputIndex - float(floorIndex) ) :
                           rgb1 , 1.0 );
}
