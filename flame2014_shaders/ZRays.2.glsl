//*****************************************************************************/
// 
// Filename: ZRays.2.glsl
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

uniform sampler2D t1;
uniform sampler2D adsk_results_pass1;
uniform vec3 rays_pos;
uniform bool white_is_far; 
uniform float adsk_result_w, adsk_result_h;

void main()
{
   vec2 textCoo = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 source = texture2D( adsk_results_pass1, textCoo ).rgb;
   float zdepth = texture2D( t1, textCoo ).r;
   
   bool visible = false;
   if ( white_is_far )
   {
      visible = (zdepth > rays_pos.z);
   }
   else
   {
      visible = (zdepth < rays_pos.z);
   }
   gl_FragColor = visible ? vec4( source, 1.0 ) : vec4( 0.0, 0.0, 0.0, 1.0 );
}
