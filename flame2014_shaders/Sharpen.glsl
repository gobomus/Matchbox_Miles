//*****************************************************************************/
// 
// Filename: Sharpen.glsl
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
uniform float adsk_t0_w, adsk_t0_h;
uniform float sharpness;
uniform bool radius_3_or_5;
uniform float adsk_result_w, adsk_result_h;

void main(void)
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec2 dp = vec2(1.0)/ vec2(adsk_t0_w,adsk_t0_h);
   vec3 val;
   if(!radius_3_or_5) {
      val = -texture2D(t0, coords - dp).rgb;
      val += -texture2D(t0, coords + vec2(0.0, -dp.y)).rgb;
      val += -texture2D(t0, coords + vec2(dp.x, -dp.y)).rgb;
      val += -texture2D(t0, coords + vec2(-dp.x, 0)).rgb;
      val += (8.0+sharpness)*texture2D(t0, coords).rgb;
      val += -texture2D(t0, coords + vec2(dp.x, 0)).rgb;
      val += -texture2D(t0, coords + vec2(-dp.x, dp.y)).rgb;
      val += -texture2D(t0, coords + vec2(0.0, dp.y)).rgb;
      val += -texture2D(t0, coords + dp).rgb;
   } else {
      vec3 val2 = texture2D(t0, coords - dp).rgb;
      val2 += texture2D(t0, coords + vec2(0.0, -dp.y)).rgb;
      val2 += texture2D(t0, coords + vec2(dp.x, -dp.y)).rgb;
      val2 += texture2D(t0, coords + vec2(-dp.x, 0)).rgb;
      val2 += texture2D(t0, coords + vec2(dp.x, 0)).rgb;
      val2 += texture2D(t0, coords + vec2(-dp.x, dp.y)).rgb;
      val2 += texture2D(t0, coords + vec2(0.0, dp.y)).rgb;
      val2 += texture2D(t0, coords + dp).rgb;

      vec3 val3 = texture2D(t0, coords - 2.0*dp).rgb;
      val3 += texture2D(t0, coords + vec2(-dp.x, -2.0*dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(0.0, -2.0*dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(dp.x, -2.0*dp.y)).rgb;
      val3 += texture2D(t0, coords + 2.0*vec2(dp.x, -dp.y)).rgb;

      val3 += texture2D(t0, coords + vec2(-2.0*dp.x, -dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(-2.0*dp.x, 0.0)).rgb;
      val3 += texture2D(t0, coords + vec2(-2.0*dp.x, dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(2.0*dp.x, -dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(2.0*dp.x, 0.0)).rgb;
      val3 += texture2D(t0, coords + vec2(2.0*dp.x, dp.y)).rgb;

      val3 += texture2D(t0, coords + 2.0*vec2(-dp.x, dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(-dp.x, 2.0*dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(0.0, 2.0*dp.y)).rgb;
      val3 += texture2D(t0, coords + vec2(dp.x, 2.0*dp.y)).rgb;
      val3 += texture2D(t0, coords + 2.0*dp).rgb;

      val = 2.0*val2 - val3 + sharpness*texture2D(t0, coords).rgb;
   }
   gl_FragColor.rgba = vec4( val*(1.0/sharpness), 1.0 );
}
