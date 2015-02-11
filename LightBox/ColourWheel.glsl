//*****************************************************************************/
//
// Filename: ColourWheel.glsl
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

// Forward declaration of API function. This is necessary to use in Matchbox otherwise it won't compiled. Please see MatchboxAPI for more info.
vec3  adsk_rgb2hsv( vec3 rgb );
vec3  adsk_hsv2rgb( vec3 hsv );


// This is the vec3 used to create a colour wheel widget
uniform vec3 colourWheel;

uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h;

void main()
{

   vec2 coords = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h );
   vec3 source = texture2D(front, coords).rgb;
   
   // This is a simple rgb to hsv convertion using the new API
   vec3 hsv = adsk_rgb2hsv( source);
   
   // Here we are using the angle of the colour wheel the set the hue
   hsv.r += colourWheel.x - 120.0 / 360.0;
   
   // Here we are using both colour wheel intensity to control saturation and value.
   // Note that I inverted the channel, so saturation could be displayed in the outer ring of the colour wheel
   hsv.g *= colourWheel.z * 0.01;
   hsv.b *= colourWheel.y * 0.001 + 1.0;
   
    // This is a simple hsv to rgb convertion using the new API
   vec3 colour = adsk_hsv2rgb( hsv );
   
   gl_FragColor =  vec4(colour, 1.0); 
}
