//*****************************************************************************/
// 
// Filename: ZRays.3.glsl
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

uniform sampler2D t0, lensTex;
uniform sampler2D adsk_results_pass2;
uniform vec3 rays_pos;
uniform float effect, lensEffect;
uniform float adsk_result_w, adsk_result_h;

void main()
{
   vec2 textCoo = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec2 sampleCoo = textCoo;
   
   // empirically, we add a number of samples in proportion to the
   // "blurcenter -> currentfragment" distance
   vec2 clampedBlurCenter = clamp( rays_pos.xy, 
                                   vec2( 0.0, 0.0 ),
                                   vec2( 1.0, 1.0 ) );
   int nbSamples = int( length( textCoo - clampedBlurCenter ) * 
                        float( 300/*samples*/ ) + float( 300/*samples*/ ) );

   float invBlurSamples = 1.0 / float( nbSamples );
   vec2 deltaTextCoord = vec2( textCoo - rays_pos.xy ) * 1.0 /*stepGain*/ *
                         invBlurSamples;

   vec3 finalColor = vec3( 0.0 );
   
   // on 500 serie gfx cards, there's a limitation of 256 samples per for loops.
   // so, we must perform nested loops. we do it in 2 steps:
   
   // first, we perform n full size loops (256 samples per loop)
   const int maxIters = 256;
   int fullLoops = nbSamples / maxIters;
   
   for ( int i = 0 ; i < fullLoops ; i++ )
   {
      for ( int j = 0 ; j < maxIters ; j++ )
      {
         vec3 sampleColor = texture2D( adsk_results_pass2, sampleCoo ).rgb;
         finalColor += sampleColor;
         sampleCoo -= deltaTextCoord;
      }
   }
   
   // and then we do the leftovers (nbSamples % 256)
   int leftOverIters = nbSamples - ( fullLoops * maxIters );
   
   for ( int i = 0 ; i < leftOverIters ; i++ )
   {
      vec3 sampleColor = texture2D( adsk_results_pass2, sampleCoo ).rgb;
      finalColor += sampleColor;
      sampleCoo -= deltaTextCoord;
   }
   
   finalColor *= invBlurSamples;
   
   vec3 front = texture2D( t0, textCoo ).rgb;
   vec3 lensColor = texture2D( lensTex, textCoo ).rgb;
   gl_FragColor = vec4( finalColor * vec3(effect) +
                        finalColor * vec3(lensEffect) * lensColor + 
                        front, 1.0 );
}
