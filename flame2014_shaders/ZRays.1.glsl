//*****************************************************************************/
// 
// Filename: ZRays.1.glsl
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

uniform vec3 rays_color;
uniform vec3 rays_pos;
uniform float rays_radius;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   vec2 coord = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );

   float fragCenterDist = 
      sqrt( ( coord.x - rays_pos.x ) * ( coord.x - rays_pos.x ) +
            ( coord.y - rays_pos.y ) * ( coord.y - rays_pos.y ) );
   if ( fragCenterDist < rays_radius && rays_radius > 0.0 )
   {
      float gain = ( rays_radius - fragCenterDist ) / rays_radius;
      vec3 gains = vec3( gain ) * rays_color;
      gl_FragColor = vec4( gains, 1.0 );
   }
   else
   {
      gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
   }
}
