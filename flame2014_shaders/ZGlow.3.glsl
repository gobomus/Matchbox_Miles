//*****************************************************************************/
// 
// Filename: ZGlow.3.glsl
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

uniform sampler2D adsk_results_pass1, adsk_results_pass2;
uniform sampler2D frontTex;
uniform float adsk_result_w, adsk_result_h;
uniform float amountX, amountY, gain1, gain2;
uniform bool gaussian, depth_view, glow_only;
uniform vec3 glowColor1, glowColor2;

void main(void)
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );

   int f0int = int(amountY);

   vec3 accu = vec3(0);
   
   float energy = 0.0;
   
   vec3 finalColor = vec3(0.0);
   
   float alpha = 1.0;
   
   if ( depth_view )
   {
      finalColor = texture2D(adsk_results_pass1, coords).rgb;
   }
   else
   {
      for( int y = -f0int; y <= f0int; y++)
      {
         vec2 currentCoord = vec2(coords.x, coords.y+float(y)/adsk_result_h);
         vec3 aSample = texture2D(adsk_results_pass2, currentCoord).rgb;
         float anEnergy = 1.0;
         if ( gaussian )
         {
            anEnergy *= 1.0 - (float(abs(float(y))) / float(f0int));
         }

         energy += anEnergy;

         accu+= aSample * anEnergy;
      }

      vec3 blurResult = 
         energy > 0.0 ? accu / float(energy) : 
                        texture2D(adsk_results_pass2, coords).rgb;

      finalColor = ( gain1 * glowColor1 + gain2 * glowColor2 ) *
                      blurResult * 0.01;
      
      alpha = length(finalColor);
      
      if ( !glow_only )
      {
         vec3 frontColor = texture2D(frontTex, coords).rgb;
         finalColor += frontColor;
      }
   }
                     
   gl_FragColor = vec4( finalColor, alpha );
}
