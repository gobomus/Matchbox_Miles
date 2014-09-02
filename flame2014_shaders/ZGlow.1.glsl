//*****************************************************************************/
// 
// Filename: ZGlow.1.glsl
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

uniform float z_origin, z_range;
uniform sampler2D frontTex, zdepthTex;
uniform float adsk_result_w, adsk_result_h;
uniform bool infinite, white_is_far;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   float zDepthValue = texture2D(zdepthTex, coords).r;
   
   float edge0 = 0.0;
   float edge1 = 1.0;
   
   if ( infinite )
   {
      if ( white_is_far )
      {
         edge0 = z_origin;
         edge1 = z_origin+z_range;
      }
      else
      {
         edge0 = z_origin;
         edge1 = z_origin-z_range;
      }
   }
   else
   {
      edge0 = z_range;
      edge1 = 0.0;
      zDepthValue = abs(z_origin-zDepthValue);
   }

   vec3 finalColor = vec3(0.0);
   
   if ( edge0 != edge1 || infinite )
   {
      float zEffect = smoothstep( edge0, edge1, zDepthValue );   
      finalColor = texture2D(frontTex, coords).rgb * zEffect;
   }
   
   gl_FragColor = vec4( finalColor, 1.0 );
}
