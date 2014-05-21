#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
uniform sampler2D adsk_results_pass1, adsk_results_pass3;


// By @paulofalcao
//
// Blobs

#ifdef GL_ES
precision highp float;
#endif

uniform float speed, adsk_time;
float time = adsk_time * speed;
vec2 resolution = vec2(adsk_result_w, adsk_result_h);
uniform vec2 center;
uniform float size;
uniform float scale;

float makePoint(float x,float y,float fx,float fy,float sx,float sy,float t){
	x -= center.x;
	y -= center.y;
	x *= adsk_result_frameratio;

   	float xx=x*cos(t/fx);
   	float yy=y*sin(t/fy);


	float c = 1.0 / (sqrt(length(xx+yy) + length(xx*yy)));

   	return c;
}

void main( void ) {
   	vec2 p = gl_FragCoord.xy / resolution.xy;

   	float x=p.x;
   	float y=p.y;


   	float a=
       	makePoint(x,y,3.3,2.9,0.3,0.3,time);
   a=a+makePoint(x,y,1.9,2.0,0.4,0.4,time);
   a=a+makePoint(x,y,0.8,0.7,0.4,0.5,time);
   a=a+makePoint(x,y,2.3,0.1,0.6,0.3,time);
   a=a+makePoint(x,y,0.8,1.7,0.5,0.4,time);
   a=a+makePoint(x,y,0.3,1.0,0.4,0.4,time);
   a=a+makePoint(x,y,1.4,1.7,0.4,0.5,time);
   a=a+makePoint(x,y,1.3,2.1,0.6,0.3,time);
   a=a+makePoint(x,y,1.8,1.7,0.5,0.4,time);   
   
   	float b=
       	makePoint(x,y,1.2,1.9,0.3,0.3,time);
   b=b+makePoint(x,y,0.7,2.7,0.4,0.4,time);
   b=b+makePoint(x,y,1.4,0.6,0.4,0.5,time);
   b=b+makePoint(x,y,2.6,0.9,0.6,0.3,time);
   b=b+makePoint(x,y,0.7,1.4,0.5,0.4,time);
   b=b+makePoint(x,y,0.7,1.7,0.4,0.4,time);
   b=b+makePoint(x,y,0.8,0.5,0.4,0.5,time);
   b=b+makePoint(x,y,1.4,0.7,0.6,0.3,time);
   b=b+makePoint(x,y,0.7,1.3,0.5,0.4,time);

   	float c=
       	makePoint(x,y,3.7,0.3,0.3,0.3,time);
   c=c+makePoint(x,y,1.9,1.3,0.4,0.4,time);
   c=c+makePoint(x,y,0.8,0.9,0.4,0.5,time);
   c=c+makePoint(x,y,1.2,1.7,0.6,0.3,time);
   c=c+makePoint(x,y,0.3,0.6,0.5,0.4,time);
   c=c+makePoint(x,y,0.3,0.3,0.4,0.4,time);
   c=c+makePoint(x,y,1.4,0.8,0.4,0.5,time);
   c=c+makePoint(x,y,0.2,0.6,0.6,0.3,time);
   c=c+makePoint(x,y,1.3,0.5,0.5,0.4,time);
   
	vec3 d = vec3(a,b,c)*0.01;
   
   	gl_FragColor = vec4(d.r,d.g,d.b,1.0);
}
