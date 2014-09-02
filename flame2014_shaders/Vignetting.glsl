//*****************************************************************************/
// 
// Filename: Vignetting.glsl
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

uniform float darkness, inner, outer;
uniform sampler2D t0;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   /// obtain the input rgb color
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 rgb = texture2D(t0, coords).rgb;
   // convert the pixel coords in -1..1 range
   vec2 pixel = -1.0 + 2.0 * coords;
   // apply the vignetting
   float vignette = 
      (1.0-darkness)+darkness*smoothstep(outer, inner, dot(pixel, pixel));
   rgb *= vignette;
   // output the result color
   gl_FragColor = vec4( rgb, vignette );
}
