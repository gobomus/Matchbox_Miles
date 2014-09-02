//*****************************************************************************/
// 
// Filename: ZFog.glsl
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

uniform float z_origin, z_range, z_gain;
uniform float lens_effect;
uniform vec2 lens_offset;
uniform sampler2D frontTex, zdepthTex, lensTex;
uniform float adsk_result_w, adsk_result_h;
uniform vec3 fogColor;
uniform bool infinite, white_is_far;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   float zDepthValue = texture2D(zdepthTex, coords).r;

   vec2 lens_coords = (gl_FragCoord.xy) / vec2( adsk_result_w, adsk_result_h ) +
                         - lens_offset;
   
   vec3 lensValue = texture2D(lensTex, lens_coords).rgb;
   
   float zEffect = 0.0;
   
   if ( infinite )
   {
      if ( white_is_far )
      {
         zEffect = smoothstep( z_origin, z_origin+z_range, zDepthValue );
      }
      else
      {
         zEffect = smoothstep( z_origin+z_range, z_origin, zDepthValue );
      }
   }
   else
   {
      zEffect = smoothstep( z_range, 0.0, abs(z_origin-zDepthValue) );
   }
   
   zEffect *= clamp( (z_gain/100.0), 0.0, 1.0 );
   
   vec3 frontColor = texture2D(frontTex, coords).rgb;
   
   vec3 finalColor = zEffect * fogColor + (1.0-zEffect) * frontColor +
                     ( lensValue * vec3(zEffect) * vec3(lens_effect/100.0) );
   
   gl_FragColor = vec4( finalColor, 1.0 );
}
