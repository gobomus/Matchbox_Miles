//*****************************************************************************/
// 
// Filename: CrossHatching.glsl
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
uniform float scale;
uniform int nbSteps;
uniform float thickness;
uniform float adsk_t0_w;
uniform float adsk_result_w, adsk_result_h;

void main()
{
  if ( nbSteps <= 0 )
  {
     gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
     return;
  }

  // current frag coords
  vec2 uv = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );

  vec3 tc = vec3(1.0, 0.0, 0.0);
  // ""luminance""
  float lum = length(texture2D(t0, uv).rgb);
  
  // default is white by default
  tc = vec3(1.0, 1.0, 1.0);
  
  float lumThreshold = 1.0;
  float lumThresholdStep = 1.0 / float(nbSteps);
  
  for (int x = 0 ; x < nbSteps ; x++ )
  {
     if (lum < lumThreshold)
     {
       if ( mod( gl_FragCoord.x + gl_FragCoord.y, 
                 scale * float(nbSteps-x) ) < thickness ||
            mod( (adsk_t0_w-gl_FragCoord.x) + gl_FragCoord.y,
                 scale * float(nbSteps-x) ) < thickness )
       {
         // hatching is black
         tc = vec3(0.0, 0.0, 0.0);
       }
     }
     lumThreshold -= lumThresholdStep;
  }
  
  gl_FragColor = vec4( tc, 1.0 );
}
