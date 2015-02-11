//*****************************************************************************/
// 
// Filename: LightboxAPISimple.glsl
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

// In this example we will show how to query the Action scene to do more advanced processing while still using the Lighting framework

uniform float adskUID_near;
uniform float adskUID_far;
uniform vec3 adskUID_tint;

vec4 adskUID_lightbox( vec4 source )
{
   
   vec3 colour = source.rgb;
   
   // Below we are using the Light position and vertex position information to determine the distance in between the two
   // to then allow to modulate the color based on Light version vertex distance
   float alpha = clamp(length(adsk_getLightPosition() - adsk_getVertexPosition()) / (adskUID_far-adskUID_near), 0.0, 1.0);
   
   vec3 result = colour * adskUID_tint;
   
   colour = mix(result, colour, alpha);
   
   return vec4 (colour, source.a);
}


// Here are all the information you can query from the Action scene using the following function calls

// vec3 adsk_getNormal()
// vec3 adsk_getBinormal()
// vec3 adsk_getTangent()
// vec3 adsk_getVertexPosition()
// vec3 adsk_getCameraPosition()
// float adsk_getTime()

// Current light information
// bool adsk_isLightActive()
// bool adsk_isLightAdditive()
// vec3 adsk_getLightPosition()
// vec3 adsk_getLightColour()
// vec3 adsk_getLightDirection()
// vec3 adsk_getLightTangent()
// float adsk_getLightDecayRate()
// bool adsk_isSpotlightFalloffParametric()
// float adsk_getSpotlightParametricFalloffIn()
// float adsk_getSpotlightParametricFalloffOut()
// float adsk_getSpotlightSpread()


// Returns precomputed alpha calculated from spotlight cutoff, decay and gmask
// float adsk_getLightAlpha()
// bool adsk_isPointSpotLight()
// bool adsk_isDirectionalLight()
// bool adsk_isAmbientLight()
// bool adsk_isAreaRectangleLight()
// bool adsk_isAreaEllipseLight()
// float adsk_getAreaLightWidth()
// float adsk_getAreaLightHeight()


// Lightbox
// false its from current lit fragment
// bool adsk_isLightboxRenderedFromDiffuse()
// false its post light
// bool adsk_isLightboxRenderedBeforeLight()


// Pre-computed multipliers 
// vec3 adsk_getComputedDiffuse()
// float adsk_getShininess()
// vec3 adsk_getComputedSpecular()


// Action maps
// vec4 adsk_getDiffuseMapValue( in vec2 texCoord )
// vec4 adsk_getEmissiveMapValue( in vec2 texCoord )
// vec4 adsk_getSpecularMapValue( in vec2 texCoord )
// vec4 adsk_getNormalMapValue( in vec2 texCoord )
// vec4 adsk_getReflectanceMapValue( in vec2 texCoord )
// vec4 adsk_getUVMapValue( in vec2 texCoord )
// vec4 adsk_getParallaxMapValue( in vec2 texCoord )


// IBL
// int adsk_getNumberIBLs()
// else its angular map
// bool adsk_isCubeMapIBL( in int idx )
// vec3 adsk_getCubeMapIBL( in int idx, in vec3 coords, float lod )
// vec3 adsk_getAngularMapIBL( in int idx, in vec2 coords, float lod )
// bool adsk_isAmbientIBL( in int idx )
// float adsk_getIBLDiffuseOffset( in int idx )
