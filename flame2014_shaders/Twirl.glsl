//*****************************************************************************/
// 
// Filename: Twirl.glsl
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
uniform float amount, frequency, bias;
uniform bool lanczos;
uniform float adsk_time, speed;
uniform float adsk_result_w, adsk_result_h;

float Lanczos3_1D(float x)
{
   const float pi = 3.1415927;
   const float pi2 = pi*pi;
   return (abs(x)<1e-9) ? 1.0 : 3.0*sin(pi*x)*sin(pi*x/3.0)/(pi2*x*x);
}

float Lanczos3_2D(vec2 p)
{
   return Lanczos3_1D(p.x)*Lanczos3_1D(p.y);
}

void main(void)
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec2 dp = vec2(adsk_t0_w,adsk_t0_h);
   vec2 inv_dp = vec2(1.0)/dp;
   vec2 r = (coords - vec2(0.5)) * dp;
   float lr = length(r);
   float theta = lr<(1e-8) ? 0.0 : atan(r.y,r.x) + 0.1*amount*cos((frequency*lr/adsk_t0_w+bias+adsk_time*speed/100.0)*6.28318);

   vec2 c=dp*vec2(0.5)+lr*vec2(cos(theta),sin(theta));

   vec4 tex0=vec4(0.0);
   if(lanczos)
   {
      vec2 spl;
      for(spl.y = floor(c.y)-2.0; spl.y<=floor(c.y)+3.0; spl.y+=1.0)
         for(spl.x = floor(c.x)-2.0; spl.x<=floor(c.x)+3.0; spl.x+=1.0)
            tex0 += texture2D(t0, spl*inv_dp) * Lanczos3_2D( c-spl ) ;
   }
   else
      tex0 = texture2D(t0, c*inv_dp);
   gl_FragColor.rgba = vec4( tex0.rgb, 1.0 );
}
