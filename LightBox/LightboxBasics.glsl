//*****************************************************************************/
//
// Filename: LightboxBasics.glsl
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

// LIGHTBOX
// While we are still in the glsl world Lightbox are quite a different beast than Matchbox in the sense that they are integrated in the Lighting shader of Action.
// So that implies a few limitation:
//  - It doesn't supports multi pass shader
//  - It cannot access neighbors fragment information, so filters are not possible
//  - There is no concept of input or output resolution
//  - The shader structure is fixed. So you absolutely need to use the one shown below where adskUID_lightbox is the required input and return the required output, both are vec4.
//  - #versions are not supported

// You do not need to do any forward declaration in Lightbox contrary to Matchbox(See MatchboxAPI example for more info on this).


// One big difference with Matchbox uniform usage is that in Lightbox you need to use the adskUID_ prefix in front of all of them to make sure you do not get uniform clashes.
// Since all Lightbox shaders end up in one large shader this is a mandatory procedure.
uniform float adskUID_gain;


// Here is where the magic happens. 
// The vec4 below is including the RGB result provided from Action rendering as well as the Alpha of the Light which includes all the 3D info of the scene.
// The example below is showing a simple use case where we only modify the RGB data, but preserve the Alpha at the return function, which means we are still leveraging the Action lighting system by doing so.
// Overwriting the Alpha means that any other Lightbox following this one will received the new Alpha and no longer the one provided by the Light they are attached to, so you need to be cautious.
// Also overwriting the Alpha while still preserving 3D data will require to recompute everything yourself using the provided API which might means quite a lot of code.
vec4 adskUID_lightbox( vec4 source )
{
   
   // This is a simple gain added to the RGB result coming in, but anything fragment based is possible.
   // Also all Matchbox widget are supported
   // Finally do not forget that you can query the scene info using the provided API to modulate any result based on it.
   source.rgb = source.rgb * adskUID_gain;
   
   // The return function giving the shader result to the next Lightbox or to the next Light based on the Priority editor ordering.
   return vec4( source.rgb, source.a );
}
