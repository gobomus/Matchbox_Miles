//*****************************************************************************/
// 
// Filename: GradientMap.glsl
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

uniform sampler2D front, warpMap;
uniform float adsk_result_w, adsk_result_h;
uniform float effect;

vec2 computeGrad(vec2 p)
{
   vec2 inv_dh = vec2(1.0)/vec2(adsk_result_w,adsk_result_h);
   float h00 = texture2D(warpMap, p-inv_dh).r;
   float h01 = texture2D(warpMap, p+vec2(0.0,-inv_dh.y)).r;
   float h02 = texture2D(warpMap, p+vec2(inv_dh.x,-inv_dh.y)).r;
   float h10 = texture2D(warpMap, p+vec2(-inv_dh.x,0.0)).r;
   float h12 = texture2D(warpMap, p+vec2(inv_dh.x,0.0)).r;
   float h20 = texture2D(warpMap, p+vec2(-inv_dh.x,inv_dh.y)).r;
   float h21 = texture2D(warpMap, p+vec2(0.0,inv_dh.y)).r;
   float h22 = texture2D(warpMap, p+inv_dh).r;
   vec3 kk = vec3(1.0,2.0,1.0);

   float dx = dot( kk, -vec3(h00,h10,h20)+vec3(h02,h12,h22));
   float dy = dot( kk, -vec3(h00,h01,h02)+vec3(h20,h21,h22));
   return vec2(dx,dy);
}

void main()
{
   vec2 frameSize = vec2( adsk_result_w, adsk_result_h );
   vec2 coords = gl_FragCoord.xy / frameSize;
   vec2 gradient = computeGrad(coords) * vec2(effect/100.0);
   gl_FragColor = vec4( gradient.x, gradient.y, 0.0, 1.0 );
}
