#version 120

uniform float adsk_result_w, adsk_result_h;
vec2 iResolution = vec2(adsk_result_w, adsk_result_h);
uniform sampler2D Front;
uniform float adsk_time;
float iGlobalTime = adsk_time;
uniform vec2 p1, p2, p3;
uniform int SIDES;
uniform float width, x1, x2, x3, x4;


// Created by Vinicius Graciano Santos - vgs/2013
// I've learned a lot about fractals in this series of blog posts:
// http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/

#define TAU 6.283185

float fractal(in vec2 uv) {
	float c = cos(1.0/float(SIDES)*TAU);
	float s = sin(1.0/float(SIDES)*TAU);
	
	//mat2 m = mat2(c, s, -s, c);
	mat2 m = mat2(c, -s, s, c);
	vec2 p = vec2(width, 0.0); 
	vec2 r = p;
	
	//for (int i = 0; i < 7; ++i) {
	for (int i = 0; i < 11; ++i) {
		float dmin = length(uv - r);
		for (int j = 0; j < SIDES; ++j) {
			p = m*p;
			float d = length(uv - p); 
			if (d < dmin) {
				dmin = d;
				r = p;
			}
		}

		//uv = 2.0*uv - r;
		uv = x2*uv - r;
	}
	
	//return (length(uv-r)-0.15)/pow(2.0, 7.0);

	return length(uv-r)/ 10.0;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	float vig = 0.15 + pow(uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.1);
	
	uv = -1.0+2.0*uv;
	uv.x *= iResolution.x/iResolution.y;
	
	float d = fractal(uv);
	//d = smoothstep(0.001, 0.015, d);
	
	//gl_FragColor = vec4(vec3(pow(vig*d, 0.45)),1.0);

	gl_FragColor = vec4(d);
}
