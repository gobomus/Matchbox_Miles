#version 120
#extension GL_ARB_shader_texture_lod : enable

//This guy is pretty bloody smart
//http://john-chapman-graphics.blogspot.com/2013/02/pseudo-lens-flare.html

uniform float adsk_result_w, adsk_result_h;
vec2 res = vec2(adsk_result_w, adsk_result_h);
vec2 texel = 1.0 / res;

uniform sampler2D adsk_results_pass8;
uniform sampler2D adsk_results_pass1;

uniform float scale_amount;
uniform int chroma_samples;


vec2 uniform_scale(vec2 coords, float scale)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec2 center = vec2(.5);

    return (coords - center) / (scale) + center;
}

float sat( float t )
{
    return clamp( t, 0.0, 1.0 );
}

float linterp( float t ) {
    return sat( 1.0 - abs( 2.0*t - 1.0 ) );
}

float remap( float t, float a, float b ) {
    return sat( (t - a) / (b - a) );
}

vec4 spectrum_offset( float t ) {
    vec3 tmp;
    vec4 ret;
    float lo = step(t,0.5);
    float hi = 1.0-lo;
    float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
    tmp = vec3(lo,1.0,hi) * vec3(1.0-w, w, 1.0-w);

    vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 lum = vec3(dot(tmp, W));

    ret = vec4(tmp, lum.r);

    return pow( ret, vec4(1.0/2.2) );
}

vec4 warp_chroma(sampler2D source, vec2 st) {
	vec4 sumcol = vec4(0.0);
	//vec4 sumcol = texture2D(source, st);
    vec4 sumw = vec4(0.0);
	float reci_num_iter_f = 1.0 / float(chroma_samples);

    for (int i=0; i < chroma_samples; i++) {
        float t = float(i) * reci_num_iter_f;
        vec4 w = spectrum_offset( t );

        sumw += w;
        vec2 coords = uniform_scale(st, 1.0 + scale_amount * t);

       	sumcol += w * texture2D(source, coords);
	}

	vec4 warped = (sumcol / sumw);

	return warped;
}

void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);
	vec4 result = warp_chroma(adsk_results_pass8, st);

	gl_FragColor = result;
}
