//*****************************************************************************/
// 
// Filename: MedianFilter.2.glsl
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
uniform float samples;
uniform float adsk_result_w, adsk_result_h;
uniform bool adsk_degrade;

void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   
   int samplesInt = int(samples+0.5);

   if ( samplesInt <= 0  )
   {
      gl_FragColor = vec4( texture2D( adsk_results_pass1, coords ).rgb, 1.0 );
      return;
   }
   
   int astep = adsk_degrade ? 2 : 1;
   
   vec3 results[512];

   // gather all the surrounding pixels
   int index = 0;
   for ( int y = -samplesInt ; y <= samplesInt ; y+=astep )
   {
      results[index] =
         texture2D( adsk_results_pass1, 
                    coords + vec2( 0.0, float(y)/adsk_result_h ) ).rgb;
      index++;
   }
  
   // bubble sort the surrounding pixels
   for ( int i = 0 ; i < index ; i++ )
   {
      for ( int j = 0 ; j < index ; j++ )
      {
         if ( length(results[i]) > length(results[j]) )
         {
            vec3 tmp = results[i];
            results[i] = results[j];
            results[j] = tmp;
         }
      }
   }
  
   gl_FragColor = vec4(results[index/2], 1.0);
}
