//*****************************************************************************/
// 
// Filename: ZGlow.2.glsl
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

uniform sampler2D adsk_results_pass1;
uniform sampler2D frontTex;
uniform float adsk_result_w, adsk_result_h;
uniform float amountX, amountY;
uniform bool gaussian, depth_view;

void main(void)
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );

   int f0int = int(amountX);

   vec3 accu = vec3(0);
   
   float energy = 0.0;
   
   vec3 finalColor = vec3(0.0);
   
   if ( depth_view )
   {
      finalColor = texture2D(adsk_results_pass1, coords).rgb;
   }
   else
   {
      for( int x = -f0int; x <= f0int; x++)
      {
         vec2 currentCoord = vec2(coords.x+float(x)/adsk_result_w, coords.y);
         vec3 aSample = texture2D(adsk_results_pass1, currentCoord).rgb;
         float anEnergy = 1.0;
         if ( gaussian )
         {
            anEnergy *= 1.0 - (float(abs(float(x))) / float(f0int));
         }

         energy += anEnergy;

         accu+= aSample * anEnergy;
      }

      finalColor = 
         energy > 0.0 ? accu / float(energy) : 
                        texture2D(adsk_results_pass1, coords).rgb;
   }
                     
   gl_FragColor.rgb = finalColor;
}
