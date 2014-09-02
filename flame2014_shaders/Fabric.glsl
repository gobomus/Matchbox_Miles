//*****************************************************************************/
// 
// Filename: Fabric.glsl
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
uniform float adsk_result_w, adsk_result_h;
uniform float size;
uniform float effect;

void main()
{
   // if size == 3, the kernel looks like this:
   //
   //        -1  2 -1
   //        -1  2 -1
   //  -1 -1 -1  2 -1 -1 -1
   //   2  2  2  2  2  2  2
   //  -1 -1 -1  2 -1 -1 -1
   //        -1  2 -1
   //        -1  2 -1

   vec2 frameSize = vec2( adsk_result_w, adsk_result_h );
   vec2 coords = gl_FragCoord.xy / frameSize;
   vec2 invWH = vec2(1.0) / frameSize;
   
   vec3 accum = vec3(0.0);
   
   int intSize = int(size+0.5);
   
   // center horizontal line (weight=2)
   for( int x = -intSize ; x < intSize ; x++ )
   {
      accum += texture2D(frontTex, coords + (invWH * vec2(x,0.0))).rgb *
               vec3(2.0);
   }

   // sides horizontal lines (weight=-1)
   for( int x = -intSize ; x < intSize ; x++ )
   {
      accum += texture2D(frontTex, coords + (invWH * vec2(x,1.0))).rgb *
               vec3(-1.0);
      accum += texture2D(frontTex, coords + (invWH * vec2(x,-1.0))).rgb *
               vec3(-1.0);
   }
   
   // center vertical line (weight=2)
   for( int y = -intSize ; y < intSize ; y++ )
   {
      accum += texture2D(frontTex, coords + (invWH * vec2(0.0,y))).rgb *
               vec3(2.0);
   }

   // sides vertical lines (weight=-1)
   for( int y = -intSize ; y < intSize ; y++ )
   {
      accum += texture2D(frontTex, coords + (invWH * vec2(1.0,y))).rgb *
               vec3(-1.0);
      accum += texture2D(frontTex, coords + (invWH * vec2(-1.0,y))).rgb *
               vec3(-1.0);
   }

   vec3 frontColor = texture2D(frontTex, coords).rgb;
   
   // we divide by 6.0 because the sum of kernel coefficients is 6.0
   gl_FragColor = vec4( frontColor + accum * vec3(effect/100.0/6.0), 1.0 );
}
