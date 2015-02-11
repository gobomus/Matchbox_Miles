//*****************************************************************************/
// 
// Filename: ColourCurves.glsl
//
// Copyright (c) 2014 Autodesk, Inc.
// All rights reserved.
// 
// This computer source code and related instructions and comments are the
// unpublished confidential and proprietary information of Autodesk, Inc.
// and are protected under applicable copyright and trade secret law.
// They may not be disclosed to, copied or used by any third party without
// the prior written consent of Autodesk, Inc.
//*****************************************************************************/


uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h;

// Forward declaration of API function. This is necessary to use in Matchbox otherwise it won't compiled. Please see MatchboxAPI for more info.
vec3  adsk_rgb2hsv( vec3 rgb );
vec3  adsk_hsv2rgb( vec3 hsv );
float adsk_getLuminance ( vec3 rgb );
vec3  adskEvalDynCurves( ivec3 curve, vec3 x );
float adskEvalDynCurves( int curve, float x );

// Here is the ivec3 used for the 3 curves Colour Curves widget
uniform ivec3 colorCurves; 

// Here is the int used for the single Luma Curve widget
uniform int lumaCurve; 


void main()
{
   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 source = texture2D(front, coords).rgb;
   
   // Since I used the Hue Colour Wheel background I'm using the API function to extract the hue
   float hue = adsk_rgb2hsv(source).r;
   
   // Here we used the provided curve evaluator to give you back a vec3 out of the 3 curves widget
   // In this example we are evaluating all 3 curves at once, but you could do them individualy like this:
   // float gain = adskEvalDynCurves(colorCurves.r, hue );
   vec3 gain=adskEvalDynCurves(colorCurves.rgb, vec3(hue) );
   
   // Here we are applying the curve result
   source = source * (gain+1.0);
   
   // Extract Luminance from source using API function
   float lum = adsk_getLuminance(source);
   
   // Here I'm evluating the single Luma curve widget
   float newLum = adskEvalDynCurves(lumaCurve,lum);
   
   // Here we are applying the curve result
   source *= lum > 0.0 ? newLum / lum : 0.0;
   
   gl_FragColor = vec4(source,1.0);
}
