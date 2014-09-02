//*****************************************************************************/
// 
// Filename: Posterise.glsl
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

uniform sampler2D t0;
uniform float Gamma;
uniform int NumColors;
uniform float adsk_result_w, adsk_result_h;

void main()
{
  // obtain the source color
  vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
  vec3 sourceColor = texture2D(t0, coords).rgb;
  // apply the gamma
  sourceColor = pow(sourceColor, vec3(Gamma));
  // scale it up by number of desired colors
  sourceColor = sourceColor * vec3(NumColors);
  // floor it to make sure the color is integer
  sourceColor = floor(sourceColor);
  // scale it down to the 0..1 range.
  sourceColor = sourceColor / vec3(NumColors);
  // applied the inverse gamma
  sourceColor = pow(sourceColor, vec3(1.0/Gamma));
  // output the color
  gl_FragColor = vec4(sourceColor, 1.0);
}
